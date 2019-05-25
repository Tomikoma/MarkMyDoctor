const mongoose=require("mongoose");

const doctorSchema = mongoose.Schema({
  name: { type: String, required: true},
  organization: {type: String, required: true}
});


module.exports = mongoose.model('Doctor', doctorSchema);
