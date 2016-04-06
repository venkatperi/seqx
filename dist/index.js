var SeqX, seqx;

SeqX = require("./lib/SeqX");

seqx = function(opts) {
  return new SeqX(opts);
};

seqx.SeqX = SeqX;

module.exports = seqx;
