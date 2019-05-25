const express = require("express");
const Doctor=require('../models/doctor');
const Rate=require('../models/rate');
const router = express.Router();


router.get("", (req, res, next) => {
  const doctorQuery = Doctor.find();
  let fetchedDoctors;
  /*if (pageSize && currentPage){
    gameQuery
      .skip(pageSize * (currentPage - 1))
      .limit(pageSize);
  }*/
  doctorQuery.then(documents => {
    fetchedDoctors = documents;
    console.log(documents)
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
/*
router.get("/years", (req, res, next) => {
  Game.distinct("releaseDate")
  .then(result => {
    res.status(200).json({
      years:result
    })
  }).catch(err => {
    console.log(err);
    res.status(500).json({
      message: "Something went wrong!"
    });
  })
});

router.get("/:id", (req, res, next) => {
  gameId= req.params.id;
  let game;
  Game.findById(gameId)
    .then(gameData => {
      game = gameData;
      res.status(200).json({
        game: game
      });
    }).catch(err => {
      console.log(err);
      res.status(500).json({
        message: "Something went wrong!"
      })
    });

});*/

router.post("", (req, res, next) => {
  name=req.body.name;
  organization=req.body.org;
  Rate.findOne({name:name,organization:organization})
  .then(doctorData => {
    if(!doctorData){
      const doctor= new Doctor({name:name,organization:organization});
      doctor.save(result =>{
        res.status(201).json({
          message: "Doctor added"
        })
      })
    } else {
      res.status(403).json({
        message: "This doctor is in the database!"
      })
    }
  })
});

/*
router.post("/rate", (req, res, next) => {
  userId=req.userData.userId;
  gameId=req.body.gameId;
  rating=req.body.rating;
  Rate.findOne({userId:userId,gameId:gameId})
  .then(rateData => {
    if(!rateData){
      const rate= new Rate({userId:userId,gameId:gameId,rating:rating});
      rate.save(result =>{
        res.status(201).json({
          message: "Game got rated"
        })
      })
    } else {
      const rate = new Rate({_id: rateData._id, userId:userId,gameId:gameId,rating:rating});
      rateId=rateData._id;
      Rate.findByIdAndUpdate({_id:rateId},{rating:rating})
        .then(result => {
          if(result.nModified === 0){
            res.status(500).json({
              message:"Couldn't update the rating"
            });
          } else {
            res.status(202).json({
              message:"Game rating updated"
            });
          }
        });
    }
  })
});

router.get("/rate/:id", (req, res, next) => {
  gameId=req.params.id;
  Rate.find({gameId:gameId})
    .then(result => {
      if(!result[0]) {

        res.status(200).json({
          rating: 0,
          count: 0
        });
      } else {
        Rate.aggregate(
    [
      {$match: {}},
      {$group: {_id:"$gameId", total: {$avg: "$rating"} } }
    ]
  ).then(result =>{
    const rating = result.filter(function(res){
      return res._id == gameId;
    })[0].total;
    Rate.countDocuments({gameId: gameId})
    .then(countData => {
      res.status(200).json({
        rating:rating,
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


});*/
module.exports = router;
