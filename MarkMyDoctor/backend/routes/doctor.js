const express = require("express");
const Doctor=require('../models/doctor');
const Rate=require('../models/rate');
const router = express.Router();




router.get("/org", (req, res, next) => {
  Doctor.distinct("organization")
  .then(orgData => {
    res.status(200).json({
      organizations: orgData
    });
  })
  .catch(err => {
    console.log(err)
    res.status(500).json({
      message: "Belső hiba lépett fel az adatok lekérdezése közben!"
    })
  })
});


router.post("", (req, res, next) => {
  name=req.body.name;
  organization=req.body.org;
  Doctor.findOne({name:name,organization:organization})
  .then(doctorData => {
    if(!doctorData){
      const doctor= new Doctor({name:name,organization:organization});
      doctor.save(result =>{
        res.status(201).json({
          message: "A doktor hozzá lett adva!"
        })
      })
    } else {
      res.status(403).json({
        message: "Ez a doktor ezzel a név/szervezet kombinációval már szerepel az adatbázisban!"
      })
    }
  })
});

router.post("/rate", (req, res, next) => {
  id = req.body.id
  uuid = req.body.uuid
  exp = req.body.exp
  kindness = req.body.kindness
  price = req.body.price
  sexiness = req.body.sexiness
  Rate.findOne({doctorId:id,uuid:uuid})
  .then(rateData => {
    if(!rateData){
      const rate = new Rate({doctorId:id,uuid:uuid,experience:exp,kindness:kindness,price:price,sexiness:sexiness});
      rate.save(result => {
        console.log(result)
        res.status(201).json({
          message: "Az értékelés sikeresen el lett mentve!"
        });
      })
    } else {
      rateId = rateData._id
      Rate.findByIdAndUpdate({_id:rateId},{experience:exp,kindness:kindness,price:price,sexiness:sexiness})
      .then(result => {
        if(result.nModified === 0){
          res.status(500).json({
            message:"Nem sikerült módosítani az értékelést!"
          });
        } else {
          res.status(202).json({
            message:"Értékelés sikeresen módosítva!"
          });
        }
      });
    }
  }).catch(err => {
    console.log(err);
    res.status(500).json({
      message: "Belső hiba lépett fel az értékelés elmentése közben!"
    });
  });

});

router.post("/organization", (req, res, next) => {
  const doctorQuery = Doctor.find({organization:req.body.organization});
  let fetchedDoctors;

  /*Rate.find().populate("doctorId").exec(function (err, doc) {
    if (err) return handleError(err);
    console.log(doc);
    // prints "The author is Ian Fleming"
  });*/ 
  doctorQuery.then(documents => {
    fetchedDoctors = documents;
    return Doctor.countDocuments();
  })
  .then(count => {
    
    res.status(200).json({
      message: "Doctors fetched successfully!",
      doctors: fetchedDoctors,
      maxDoctors: count
    });
  })
});

router.get("/rate/:id", (req, res, next) => {
  doctorId=req.params.id;
  Rate.find({doctorId:doctorId})
    .then(result => {
      if(!result[0]) {

        res.status(200).json({
          exp: 0,
          price: 0,
          kindness: 0,
          sexiness: 0,
          count: 0
        });
      } else {
        Rate.aggregate(
    [
      {$match: {}},
      {$group: {_id:"$doctorId", exp: {$avg: "$experience"}, price: {$avg: "$price"}, kindness: {$avg: "$kindness"}, sexiness: {$avg: "$sexiness"} } }
    ]
  ).then(result =>{
    const exp = result.filter(function(res){
      return res._id == doctorId;
    })[0].exp;
    const price = result.filter(function(res){
      return res._id == doctorId;
    })[0].price;
    const kindness = result.filter(function(res){
      return res._id == doctorId;
    })[0].kindness;
    const sexiness = result.filter(function(res){
      return res._id == doctorId;
    })[0].sexiness;

    Rate.countDocuments({doctorId: doctorId})
    .then(countData => {
      res.status(200).json({
        exp:exp,
        price: price,
        kindness: kindness,
        sexiness:sexiness,
        count: countData
      });
    }).catch(err => {
      console.log(err);
      res.status(500).json({
        message: "Something went wrong!(Rate)"
      });
    });
  }).catch(err => {
    console.log(err);
    res.status(500).json({
      message: "Something went wrong!(Rate)"
    });
  });
      }
    }).catch(err => {
      console.log(err);
      res.status(500).json({
        message: "Something went wrong!(Rate)"
      })
    })


});
module.exports = router;
