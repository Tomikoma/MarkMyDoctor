const mongoose=require("mongoose");

const rateSchema = mongoose.Schema({
  doctorId: { type: mongoose.Schema.Types.ObjectId, required: true},
  experience: { type: Number, required: true},
  kindness: { type: Number, required: true},
  price: { type: Number, required: true},
  sexiness: { type: Number, required: true},
});


module.exports = mongoose.model('Rate', rateSchema);
