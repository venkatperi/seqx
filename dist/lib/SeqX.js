var EventEmitter, Q, SeqX,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

Q = require('q');

EventEmitter = require("events").EventEmitter;

module.exports = SeqX = (function(_super) {
  __extends(SeqX, _super);

  function SeqX(opts) {
    if (opts == null) {
      opts = {};
    }
    this.actualAdd = __bind(this.actualAdd, this);
    this.abort = __bind(this.abort, this);
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
    this._abort = false;
    this.count = 0;
    if (!this.manual) {
      this.start();
    }
  }

  SeqX.prototype.start = function() {
    if (this.started) {
      return;
    }
    this.started = true;
    this.initial.resolve(true);
    return this.emit("start");
  };

  SeqX.prototype.add = function() {
    var f, fn, _i, _len;
    fn = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    for (_i = 0, _len = fn.length; _i < _len; _i++) {
      f = fn[_i];
      this.actualAdd(f);
    }
    return this.task;
  };

  SeqX.prototype.addn = function(fn, n) {
    var i, _i, _ref;
    for (i = _i = 0, _ref = n - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      this.actualAdd(fn);
    }
    return this.task;
  };

  SeqX.prototype.abort = function() {
    this._abort = true;
    return this.emit("abort");
  };

  SeqX.prototype.actualAdd = function(fn) {
    var f;
    f = (function(_this) {
      return function(args) {
        return Q.fcall(fn, args, _this.count++, _this.context);
      };
    })(this);
    this.task = this.task.then((function(_this) {
      return function(args) {
        if (_this._abort) {
          throw new Error("Aborted by user");
        }
        return f(args);
      };
    })(this));
    return this.emit("task", fn);
  };

  return SeqX;

})(EventEmitter);
