var Seq, seq;

Seq = require("./lib/Seq");

seq = function(opts) {
  return new Seq(opts);
};

seq.Seq = Seq;

module.exports = seq;
