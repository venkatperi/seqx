var Q, Seq,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

Q = require('q');

module.exports = Seq = (function() {
  function Seq(opts) {
    if (opts == null) {
      opts = {};
    }
    this.actualAdd = __bind(this.actualAdd, this);
    this.addn = __bind(this.addn, this);
    this.add = __bind(this.add, this);
    this.start = __bind(this.start, this);
    this.manual = opts.manual || false;
    if (opts.context != null) {
      this.context = opts.context;
    }
    this.initial = Q.defer();
    this.task = this.initial.promise;
    this.started = false;
    this.taskQueue = [];
    this.count = 0;
    if (!this.manual) {
      this.start();
    }
  }

  Seq.prototype.start = function() {
    if (this.started) {
      return;
    }
    this.started = true;
    return this.initial.resolve(true);
  };

  Seq.prototype.add = function() {
    var f, fn, _i, _len;
    fn = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    for (_i = 0, _len = fn.length; _i < _len; _i++) {
      f = fn[_i];
      this.actualAdd(f);
    }
    return this.task;
  };

  Seq.prototype.addn = function(fn, n) {
    var i, _i, _ref;
    for (i = _i = 0, _ref = n - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      this.actualAdd(fn);
    }
    return this.task;
  };

  Seq.prototype.actualAdd = function(fn) {
    var f;
    f = (function(_this) {
      return function(args) {
        return Q.fcall(fn, args, _this.count++, _this.context);
      };
    })(this);
    return this.task = this.task.then(f);
  };

  return Seq;

})();
