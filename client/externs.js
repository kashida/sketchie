////////////////////////////////////////////////////////////
// Wacom.

/** @constructor */
var WacomPlugin = function() {};

/** @type {string} */
WacomPlugin.prototype.version;

/** @constructor */
var WacomPenAPI = function() {};

/** @type {string} */
WacomPenAPI.prototype.version;

/** @type {string} */
WacomPenAPI.prototype.tabletModel;

/** @type {boolean} */
WacomPenAPI.prototype.isWacom;

/** @type {number} */
WacomPenAPI.prototype.pointerType;

/** @type {boolean} */
WacomPenAPI.prototype.isEraser;

/** @type {number} */
WacomPenAPI.prototype.pressure;

/** @type {number} */
WacomPenAPI.prototype.posX;
/** @type {number} */
WacomPenAPI.prototype.posY;

/** @type {number} */
WacomPenAPI.prototype.sysX;
/** @type {number} */
WacomPenAPI.prototype.sysY;

/** @type {number} */
WacomPenAPI.prototype.tabX;
/** @type {number} */
WacomPenAPI.prototype.tabY;

/** @type {number} */
WacomPenAPI.prototype.tiltX;
/** @type {number} */
WacomPenAPI.prototype.tiltY;


////////////////////////////////////////////////////////////
// Chrome extensions.

/** @const */
chrome.syncFileSystem = {};

/** @param {function(FileSystem)} callback */
chrome.syncFileSystem.requestFileSystem = function(callback) {};

/**
 * @param {FileSystem} fs
 * @param {function(Object)} callback
 */
chrome.syncFileSystem.getUsageAndQuota = function(fs, callback) {};


////////////////////////////////////////////////////////////
// Config param.

/** @const {boolean} */
var run_as_extension
