/*
 PluginDetect v0.8.9
 www.pinlady.net/PluginDetect/license/
 [ AdobeReader ]
 [ isMinVersion getVersion hasMimeType ]
 [ AllowActiveX ]
 */
(function () {
    var j = {
        version: "0.8.9",
        name: "PluginDetect",
        addPlugin: function (p, q) {
            if (p && j.isString(p) && q && j.isFunc(q.getVersion)) {
                p = p.replace(/\s/g, "").toLowerCase();
                j.Plugins[p] = q;
                if (!j.isDefined(q.getVersionDone)) {
                    q.installed = null;
                    q.version = null;
                    q.version0 = null;
                    q.getVersionDone = null;
                    q.pluginName = p;
                }
            }
        },
        openTag: "<",
        hasOwnPROP: ({}).constructor.prototype.hasOwnProperty,
        hasOwn: function (s, t) {
            var p;
            try {
                p = j.hasOwnPROP.call(s, t)
            } catch (q) {
            }
            return !!p
        },
        rgx: {str: /string/i, num: /number/i, fun: /function/i, arr: /array/i},
        toString: ({}).constructor.prototype.toString,
        isDefined: function (p) {
            return typeof p != "undefined"
        },
        isArray: function (p) {
            return j.rgx.arr.test(j.toString.call(p))
        },
        isString: function (p) {
            return j.rgx.str.test(j.toString.call(p))
        },
        isNum: function (p) {
            return j.rgx.num.test(j.toString.call(p))
        },
        isStrNum: function (p) {
            return j.isString(p) && (/\d/).test(p)
        },
        isFunc: function (p) {
            return j.rgx.fun.test(j.toString.call(p))
        },
        getNumRegx: /[\d][\d\.\_,\-]*/,
        splitNumRegx: /[\.\_,\-]/g,
        getNum: function (q, r) {
            var p = j.isStrNum(q) ? (j.isDefined(r) ? new RegExp(r) : j.getNumRegx).exec(q) : null;
            return p ? p[0] : null
        },
        compareNums: function (w, u, t) {
            var s, r, q, v = parseInt;
            if (j.isStrNum(w) && j.isStrNum(u)) {
                if (j.isDefined(t) && t.compareNums) {
                    return t.compareNums(w, u)
                }
                s = w.split(j.splitNumRegx);
                r = u.split(j.splitNumRegx);
                for (q = 0; q < Math.min(s.length, r.length); q++) {
                    if (v(s[q], 10) > v(r[q], 10)) {
                        return 1
                    }
                    if (v(s[q], 10) < v(r[q], 10)) {
                        return -1
                    }
                }
            }
            return 0
        },
        formatNum: function (q, r) {
            var p, s;
            if (!j.isStrNum(q)) {
                return null
            }
            if (!j.isNum(r)) {
                r = 4
            }
            r--;
            s = q.replace(/\s/g, "").split(j.splitNumRegx).concat(["0", "0", "0", "0"]);
            for (p = 0; p < 4; p++) {
                if (/^(0+)(.+)$/.test(s[p])) {
                    s[p] = RegExp.$2
                }
                if (p > r || !(/\d/).test(s[p])) {
                    s[p] = "0"
                }
            }
            return s.slice(0, 4).join(",")
        },
        pd: {
            getPROP: function (s, q, p) {
                try {
                    if (s) {
                        p = s[q]
                    }
                } catch (r) {
                }
                return p
            }, findNavPlugin: function (u) {
                if (u.dbug) {
                    return u.dbug
                }
                var A = null;
                if (window.navigator) {
                    var z = {
                        Find: j.isString(u.find) ? new RegExp(u.find, "i") : u.find,
                        Find2: j.isString(u.find2) ? new RegExp(u.find2, "i") : u.find2,
                        Avoid: u.avoid ? (j.isString(u.avoid) ? new RegExp(u.avoid, "i") : u.avoid) : 0,
                        Num: u.num ? /\d/ : 0
                    }, s, r, t, y, x, q, p = navigator.mimeTypes, w = navigator.plugins;
                    if (u.mimes && p) {
                        y = j.isArray(u.mimes) ? [].concat(u.mimes) : (j.isString(u.mimes) ? [u.mimes] : []);
                        for (s = 0; s < y.length; s++) {
                            r = 0;
                            try {
                                if (j.isString(y[s]) && /[^\s]/.test(y[s])) {
                                    r = p[y[s]].enabledPlugin
                                }
                            } catch (v) {
                            }
                            if (r) {
                                t = this.findNavPlugin_(r, z);
                                if (t.obj) {
                                    A = t.obj
                                }
                                if (A && !j.dbug) {
                                    return A
                                }
                            }
                        }
                    }
                    if (u.plugins && w) {
                        x = j.isArray(u.plugins) ? [].concat(u.plugins) : (j.isString(u.plugins) ? [u.plugins] : []);
                        for (s = 0; s < x.length; s++) {
                            r = 0;
                            try {
                                if (x[s] && j.isString(x[s])) {
                                    r = w[x[s]]
                                }
                            } catch (v) {
                            }
                            if (r) {
                                t = this.findNavPlugin_(r, z);
                                if (t.obj) {
                                    A = t.obj
                                }
                                if (A && !j.dbug) {
                                    return A
                                }
                            }
                        }
                        q = w.length;
                        if (j.isNum(q)) {
                            for (s = 0; s < q; s++) {
                                r = 0;
                                try {
                                    r = w[s]
                                } catch (v) {
                                }
                                if (r) {
                                    t = this.findNavPlugin_(r, z);
                                    if (t.obj) {
                                        A = t.obj
                                    }
                                    if (A && !j.dbug) {
                                        return A
                                    }
                                }
                            }
                        }
                    }
                }
                return A
            }, findNavPlugin_: function (t, s) {
                var r = t.description || "", q = t.name || "", p = {};
                if ((s.Find.test(r) && (!s.Find2 || s.Find2.test(q)) && (!s.Num || s.Num.test(RegExp.leftContext + RegExp.rightContext))) || (s.Find.test(q) && (!s.Find2 || s.Find2.test(r)) && (!s.Num || s.Num.test(RegExp.leftContext + RegExp.rightContext)))) {
                    if (!s.Avoid || !(s.Avoid.test(r) || s.Avoid.test(q))) {
                        p.obj = t
                    }
                }
                return p
            }, getVersionDelimiter: ",", findPlugin: function (r) {
                var q, p = {status: -3, plugin: 0};
                if (!j.isString(r)) {
                    return p
                }
                if (r.length == 1) {
                    this.getVersionDelimiter = r;
                    return p
                }
                r = r.toLowerCase().replace(/\s/g, "");
                q = j.Plugins[r];
                if (!q || !q.getVersion) {
                    return p
                }
                p.plugin = q;
                p.status = 1;
                return p
            }
        },
        getPluginFileVersion: function (u, q) {
            var t, s, v, p, r = -1;
            if (!u) {
                return q
            }
            if (u.version) {
                t = j.getNum(u.version + "")
            }
            if (!t || !q) {
                return q || t || null
            }
            t = j.formatNum(t);
            q = j.formatNum(q);
            s = q.split(j.splitNumRegx);
            v = t.split(j.splitNumRegx);
            for (p = 0; p < s.length; p++) {
                if (r > -1 && p > r && s[p] != "0") {
                    return q
                }
                if (v[p] != s[p]) {
                    if (r == -1) {
                        r = p
                    }
                    if (s[p] != "0") {
                        return q
                    }
                }
            }
            return t
        },
        AXO: (function () {
            var q;
            try {
                q = new window.ActiveXObject()
            } catch (p) {
            }
            return q ? null : window.ActiveXObject
        })(),
        getAXO: function (p) {
            var r = null;
            try {
                r = new j.AXO(p)
            } catch (q) {
                j.errObj = q;
            }
            if (r) {
                j.browser.ActiveXEnabled = !0
            }
            return r
        },
        browser: {
            detectPlatform: function () {
                var r = this, q, p = window.navigator ? navigator.platform || "" : "";
                j.OS = 100;
                if (p) {
                    var s = ["Win", 1, "Mac", 2, "Linux", 3, "FreeBSD", 4, "iPhone", 21.1, "iPod", 21.2, "iPad", 21.3, "Win.*CE", 22.1, "Win.*Mobile", 22.2, "Pocket\\s*PC", 22.3, "", 100];
                    for (q = s.length - 2; q >= 0; q = q - 2) {
                        if (s[q] && new RegExp(s[q], "i").test(p)) {
                            j.OS = s[q + 1];
                            break
                        }
                    }
                }
            }, detectIE: function () {
                var r = this, u = document, t, q, v = window.navigator ? navigator.userAgent || "" : "", w, p, y;
                r.ActiveXFilteringEnabled = !1;
                r.ActiveXEnabled = !1;
                try {
                    r.ActiveXFilteringEnabled = !!window.external.msActiveXFilteringEnabled()
                } catch (s) {
                }
                p = ["Msxml2.XMLHTTP", "Msxml2.DOMDocument", "Microsoft.XMLDOM", "TDCCtl.TDCCtl", "Shell.UIHelper", "HtmlDlgSafeHelper.HtmlDlgSafeHelper", "Scripting.Dictionary"];
                y = ["WMPlayer.OCX", "ShockwaveFlash.ShockwaveFlash", "AgControl.AgControl"];
                w = p.concat(y);
                for (t = 0; t < w.length; t++) {
                    if (j.getAXO(w[t]) && !j.dbug) {
                        break
                    }
                }
                if (r.ActiveXEnabled && r.ActiveXFilteringEnabled) {
                    for (t = 0; t < y.length; t++) {
                        if (j.getAXO(y[t])) {
                            r.ActiveXFilteringEnabled = !1;
                            break
                        }
                    }
                }
                q = u.documentMode;
                try {
                    u.documentMode = ""
                } catch (s) {
                }
                r.isIE = r.ActiveXEnabled;
                r.isIE = r.isIE || j.isNum(u.documentMode) || new Function("return/*@cc_on!@*/!1")();
                try {
                    u.documentMode = q
                } catch (s) {
                }
                r.verIE = null;
                if (r.isIE) {
                    r.verIE = (j.isNum(u.documentMode) && u.documentMode >= 7 ? u.documentMode : 0) || ((/^(?:.*?[^a-zA-Z])??(?:MSIE|rv\s*\:)\s*(\d+\.?\d*)/i).test(v) ? parseFloat(RegExp.$1, 10) : 7)
                }
            }, detectNonIE: function () {
                var p = this, s = window.navigator ? navigator : {}, r = p.isIE ? "" : s.userAgent || "", t = s.vendor || "", q = s.product || "";
                p.isGecko = (/Gecko/i).test(q) && (/Gecko\s*\/\s*\d/i).test(r);
                p.verGecko = p.isGecko ? j.formatNum((/rv\s*\:\s*([\.\,\d]+)/i).test(r) ? RegExp.$1 : "0.9") : null;
                p.isOpera = (/(OPR\s*\/|Opera\s*\/\s*\d.*\s*Version\s*\/|Opera\s*[\/]?)\s*(\d+[\.,\d]*)/i).test(r);
                p.verOpera = p.isOpera ? j.formatNum(RegExp.$2) : null;
                p.isChrome = !p.isOpera && (/(Chrome|CriOS)\s*\/\s*(\d[\d\.]*)/i).test(r);
                p.verChrome = p.isChrome ? j.formatNum(RegExp.$2) : null;
                p.isSafari = !p.isOpera && !p.isChrome && ((/Apple/i).test(t) || !t) && (/Safari\s*\/\s*(\d[\d\.]*)/i).test(r);
                p.verSafari = p.isSafari && (/Version\s*\/\s*(\d[\d\.]*)/i).test(r) ? j.formatNum(RegExp.$1) : null;
            }, init: function () {
                var p = this;
                p.detectPlatform();
                p.detectIE();
                p.detectNonIE()
            }
        },
        init: {
            hasRun: 0, library: function () {
                window[j.name] = j;
                var q = this, p = document;
                j.win.init();
                j.head = p.getElementsByTagName("head")[0] || p.getElementsByTagName("body")[0] || p.body || null;
                j.browser.init();
                q.hasRun = 1;
            }
        },
        ev: {
            handler: function (t, s, r, q, p) {
                return function () {
                    t(s, r, q, p)
                }
            }, setTimeout: function (q, p) {
                if (j.win && j.win.unload) {
                    return
                }
                setTimeout(q, p)
            }, fPush: function (q, p) {
                if (j.isArray(p) && (j.isFunc(q) || (j.isArray(q) && q.length > 0 && j.isFunc(q[0])))) {
                    p.push(q)
                }
            }, call0: function (q) {
                var p = j.isArray(q) ? q.length : -1;
                if (p > 0 && j.isFunc(q[0])) {
                    q[0](j, p > 1 ? q[1] : 0, p > 2 ? q[2] : 0, p > 3 ? q[3] : 0)
                } else {
                    if (j.isFunc(q)) {
                        q(j)
                    }
                }
            }, callArray0: function (p) {
                var q = this, r;
                if (j.isArray(p)) {
                    while (p.length) {
                        r = p[0];
                        p.splice(0, 1);
                        if (j.win && j.win.unload && p !== j.win.unloadHndlrs) {
                        } else {
                            q.call0(r)
                        }
                    }
                }
            }, call: function (q) {
                var p = this;
                p.call0(q);
                p.ifDetectDoneCallHndlrs()
            }, callArray: function (p) {
                var q = this;
                q.callArray0(p);
                q.ifDetectDoneCallHndlrs()
            }, allDoneHndlrs: [], ifDetectDoneCallHndlrs: function () {
                var r = this, p, q;
                if (!r.allDoneHndlrs.length) {
                    return
                }
                if (j.win) {
                    if (!j.win.loaded || j.win.loadPrvtHndlrs.length || j.win.loadPblcHndlrs.length) {
                        return
                    }
                }
                if (j.Plugins) {
                    for (p in j.Plugins) {
                        if (j.hasOwn(j.Plugins, p)) {
                            q = j.Plugins[p];
                            if (q && j.isFunc(q.getVersion)) {
                                if (q.OTF == 3 || (q.DoneHndlrs && q.DoneHndlrs.length) || (q.BIHndlrs && q.BIHndlrs.length)) {
                                    return
                                }
                            }
                        }
                    }
                }
                r.callArray0(r.allDoneHndlrs);
            }
        },
        isMinVersion: function (v, u, r, q) {
            var s = j.pd.findPlugin(v), t, p = -1;
            if (s.status < 0) {
                return s.status
            }
            t = s.plugin;
            u = j.formatNum(j.isNum(u) ? u.toString() : (j.isStrNum(u) ? j.getNum(u) : "0"));
            if (t.getVersionDone != 1) {
                t.getVersion(u, r, q);
                if (t.getVersionDone === null) {
                    t.getVersionDone = 1
                }
            }
            if (t.installed !== null) {
                p = t.installed <= 0.5 ? t.installed : (t.installed == 0.7 ? 1 : (t.version === null ? 0 : (j.compareNums(t.version, u, t) >= 0 ? 1 : -0.1)))
            }
            return p
        },
        getVersion: function (u, r, q) {
            var s = j.pd.findPlugin(u), t, p;
            if (s.status < 0) {
                return null
            }
            t = s.plugin;
            if (t.getVersionDone != 1) {
                t.getVersion(null, r, q);
                if (t.getVersionDone === null) {
                    t.getVersionDone = 1
                }
            }
            p = (t.version || t.version0);
            p = p ? p.replace(j.splitNumRegx, j.pd.getVersionDelimiter) : p;
            return p
        },
        hasMimeType: function (t) {
            if (t && window.navigator && navigator.mimeTypes) {
                var w, v, q, s, p = navigator.mimeTypes, r = j.isArray(t) ? [].concat(t) : (j.isString(t) ? [t] : []);
                s = r.length;
                for (q = 0; q < s; q++) {
                    w = 0;
                    try {
                        if (j.isString(r[q]) && /[^\s]/.test(r[q])) {
                            w = p[r[q]]
                        }
                    } catch (u) {
                    }
                    v = w ? w.enabledPlugin : 0;
                    if (v && (v.name || v.description)) {
                        return w
                    }
                }
            }
            return null
        },
        win: {
            disable: function () {
                this.cancel = true
            }, cancel: false, loaded: false, unload: false, hasRun: 0, init: function () {
                var p = this;
                if (!p.hasRun) {
                    p.hasRun = 1;
                    if ((/complete/i).test(document.readyState || "")) {
                        p.loaded = true;
                    } else {
                        p.addEvent("load", p.onLoad)
                    }
                    p.addEvent("unload", p.onUnload)
                }
            }, addEvent: function (r, q) {
                var s = this, p = window;
                if (p.addEventListener) {
                    p.addEventListener(r, q, false)
                } else {
                    if (p.attachEvent) {
                        p.attachEvent("on" + r, q)
                    } else {
                        p["on" + r] = s.concatFn(q, p["on" + r])
                    }
                }
            }, removeEvent: function (r, q) {
                var p = window;
                if (p.removeEventListener) {
                    p.removeEventListener(r, q, false)
                } else {
                    if (p.detachEvent) {
                        p.detachEvent("on" + r, q)
                    }
                }
            }, concatFn: function (q, p) {
                return function () {
                    q();
                    if (typeof p == "function") {
                        p()
                    }
                }
            }, loadPrvtHndlrs: [], loadPblcHndlrs: [], unloadHndlrs: [], onUnload: function () {
                var p = j.win;
                if (p.unload) {
                    return
                }
                p.unload = true;
                p.removeEvent("load", p.onLoad);
                p.removeEvent("unload", p.onUnload);
                j.ev.callArray(p.unloadHndlrs)
            }, count: 0, countMax: 1, intervalLength: 10, onLoad: function () {
                var p = j.win;
                if (p.loaded || p.unload || p.cancel) {
                    return
                }
                if (p.count < p.countMax && p.loadPrvtHndlrs.length) {
                    j.ev.setTimeout(p.onLoad, p.intervalLength)
                } else {
                    p.loaded = true;
                    j.ev.callArray(p.loadPrvtHndlrs);
                    j.ev.callArray(p.loadPblcHndlrs);
                }
                p.count++
            }
        },
        DOM: {
            isEnabled: {
                objectTag: function () {
                    var q = j.browser, p = q.isIE ? 0 : 1;
                    if (q.ActiveXEnabled) {
                        p = 1
                    }
                    return !!p
                }, objectTagUsingActiveX: function () {
                    var p = 0;
                    if (j.browser.ActiveXEnabled) {
                        p = 1
                    }
                    return !!p
                }, objectProperty: function (p) {
                    if (p && p.tagName && j.browser.isIE) {
                        if ((/applet/i).test(p.tagName)) {
                            return (!this.objectTag() || j.isDefined(j.pd.getPROP(document.createElement("object"), "object")) ? 1 : 0)
                        }
                        return j.isDefined(j.pd.getPROP(document.createElement(p.tagName), "object")) ? 1 : 0
                    }
                    return 0
                }
            }, HTML: [], div: null, divID: "plugindetect", divWidth: 300, getDiv: function () {
                return this.div || document.getElementById(this.divID) || null
            }, initDiv: function () {
                var q = this, p;
                if (!q.div) {
                    p = q.getDiv();
                    if (p) {
                        q.div = p;
                    } else {
                        q.div = document.createElement("div");
                        q.div.id = q.divID;
                        q.setStyle(q.div, q.getStyle.div());
                        q.insertDivInBody(q.div)
                    }
                    j.ev.fPush([q.onUnload, q], j.win.unloadHndlrs)
                }
                p = 0
            }, pluginSize: 1, altHTML: "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", emptyNode: function (q) {
                var p = this;
                if (q && (/div|span/i).test(q.tagName || "")) {
                    if (j.browser.isIE) {
                        p.setStyle(q, ["display", "none"])
                    }
                    try {
                        q.innerHTML = ""
                    } catch (r) {
                    }
                }
            }, removeNode: function (p) {
                try {
                    if (p && p.parentNode) {
                        p.parentNode.removeChild(p)
                    }
                } catch (q) {
                }
            }, onUnload: function (u, t) {
                var r, q, s, v, w = t.HTML, p = w.length;
                if (p) {
                    for (q = p - 1; q >= 0; q--) {
                        v = w[q];
                        if (v) {
                            t.emptyNode(v.span);
                            t.removeNode(v.span);
                            v.span = null
                        }
                        w[q] = 0
                    }
                }
                r = t.getDiv();
                t.emptyNode(r);
                t.removeNode(r);
                s = 0;
                r = 0;
                t.div = 0
            }, width: function () {
                var t = this, s = t.span, q, r, p = -1;
                q = s && j.isNum(s.scrollWidth) ? s.scrollWidth : p;
                r = s && j.isNum(s.offsetWidth) ? s.offsetWidth : p;
                s = 0;
                return r > 0 ? r : (q > 0 ? q : Math.max(r, q))
            }, obj: function () {
                return this.span ? this.span.firstChild || null : null
            }, readyState: function () {
                var p = this;
                return j.browser.isIE && j.isDefined(j.pd.getPROP(p.span, "readyState")) ? j.pd.getPROP(p.obj(), "readyState") : j.UNDEFINED
            }, objectProperty: function () {
                var r = this, q = r.DOM, p;
                if (q.isEnabled.objectProperty(r)) {
                    p = j.pd.getPROP(r.obj(), "object")
                }
                return p
            }, getTagStatus: function (q, A, F, E, t, D, v) {
                var G = this;
                if (!q || !q.span) {
                    return -2
                }
                var y = q.width(), r = q.obj() ? 1 : 0, s = q.readyState(), p = q.objectProperty();
                if (p) {
                    return 1.5
                }
                var u = /clsid\s*\:/i, C = F && u.test(F.outerHTML || "") ? F : (E && u.test(E.outerHTML || "") ? E : 0), w = F && !u.test(F.outerHTML || "") ? F : (E && !u.test(E.outerHTML || "") ? E : 0), z = q && u.test(q.outerHTML || "") ? C : w;
                if (!A || !A.span || !z || !z.span) {
                    return 0
                }
                var x = z.width(), B = A.width(), H = z.readyState();
                if (y < 0 || x < 0 || B <= G.pluginSize) {
                    return 0
                }
                if (v && !q.pi && j.isDefined(p) && j.browser.isIE && q.tagName == z.tagName && q.time <= z.time && y === x && s === 0 && H !== 0) {
                    q.pi = 1
                }
                if (x < B) {
                    return q.pi ? -0.1 : 0
                }
                if (y == B || !r) {
                    if (!q.winLoaded && D) {
                        return q.pi ? -0.5 : -1
                    }
                    if (j.isNum(t)) {
                        if (!j.isNum(q.count2)) {
                            q.count2 = t
                        }
                        if (t - q.count2 > 0) {
                            return q.pi ? -0.5 : -1
                        }
                    }
                } else {
                    if (y == G.pluginSize && r && (!j.isNum(s) || s === 4)) {
                        if (!q.winLoaded && D) {
                            return 1
                        }
                        if (j.isNum(t)) {
                            if (!j.isNum(q.count)) {
                                q.count = t
                            }
                            if (q.winLoaded && t - q.count > 4) {
                                return 1
                            }
                        }
                    } else {
                        if (!q.winLoaded && D) {
                            return q.pi ? -0.5 : -1
                        }
                        if (j.isNum(t)) {
                            if (!j.isNum(q.count3)) {
                                q.count3 = t
                            }
                            if (q.winLoaded && q.count3 - t > 6) {
                                return q.pi ? -0.5 : -1
                            }
                        }
                    }
                }
                return q.pi ? -0.1 : 0
            }, setStyle: function (q, t) {
                var s = q.style, p;
                if (s && t) {
                    for (p = 0; p < t.length; p = p + 2) {
                        try {
                            s[t[p]] = t[p + 1]
                        } catch (r) {
                        }
                    }
                }
                q = 0;
                s = 0
            }, getStyle: {
                span: function () {
                    var p = j.DOM;
                    return [].concat(this.Default).concat(["display", "inline", "fontSize", (p.pluginSize + 3) + "px", "lineHeight", (p.pluginSize + 3) + "px"])
                },
                div: function () {
                    var p = j.DOM;
                    return [].concat(this.Default).concat(["display", "block", "width", p.divWidth + "px", "height", (p.pluginSize + 3) + "px", "fontSize", (p.pluginSize + 3) + "px", "lineHeight", (p.pluginSize + 3) + "px", "position", "absolute", "right", "9999px", "top", "-9999px"])
                },
                plugin: function (q) {
                    var p = j.DOM;
                    return "background-color:transparent;background-image:none;vertical-align:baseline;outline-style:none;border-style:none;padding:0px;margin:0px;visibility:" + (q ? "hidden;" : "visible;") + "display:inline;font-size:" + (p.pluginSize + 3) + "px;line-height:" + (p.pluginSize + 3) + "px;"
                },
                Default: ["backgroundColor", "transparent", "backgroundImage", "none", "verticalAlign", "baseline", "outlineStyle", "none", "borderStyle", "none", "padding", "0px", "margin", "0px", "visibility", "visible"]
            }, insertDivInBody: function (v, t) {
                var u = "pd33993399", q = null, s = t ? window.top.document : window.document, p = s.getElementsByTagName("body")[0] || s.body;
                if (!p) {
                    try {
                        s.write('<div id="' + u + '">.' + j.openTag + "/div>");
                        q = s.getElementById(u)
                    } catch (r) {
                    }
                }
                p = s.getElementsByTagName("body")[0] || s.body;
                if (p) {
                    p.insertBefore(v, p.firstChild);
                    if (q) {
                        p.removeChild(q)
                    }
                }
                v = 0
            }, insert: function (u, t, v, p, y, w, B) {
                var E = this, A = document, G, F, D = A.createElement("span"), s, C;
                if (!j.isDefined(p)) {
                    p = ""
                }
                if (j.isString(u) && (/[^\s]/).test(u)) {
                    u = u.toLowerCase().replace(/\s/g, "");
                    G = j.openTag + u + " ";
                    G += 'style="' + E.getStyle.plugin(w) + '" ';
                    var r = 1, q = 1;
                    for (C = 0; C < t.length; C = C + 2) {
                        if (/[^\s]/.test(t[C + 1])) {
                            G += t[C] + '="' + t[C + 1] + '" '
                        }
                        if ((/width/i).test(t[C])) {
                            r = 0
                        }
                        if ((/height/i).test(t[C])) {
                            q = 0
                        }
                    }
                    G += (r ? 'width="' + E.pluginSize + '" ' : "") + (q ? 'height="' + E.pluginSize + '" ' : "");
                    if (u == "embed") {
                        G += " />"
                    } else {
                        G += ">";
                        for (C = 0; C < v.length; C = C + 2) {
                            if (/[^\s]/.test(v[C + 1])) {
                                G += j.openTag + 'param name="' + v[C] + '" value="' + v[C + 1] + '" />'
                            }
                        }
                        G += p + j.openTag + "/" + u + ">"
                    }
                } else {
                    u = "";
                    G = p
                }
                if (!B) {
                    E.initDiv()
                }
                s = B || E.getDiv();
                F = {
                    span: null,
                    winLoaded: j.win.loaded,
                    tagName: u,
                    outerHTML: G,
                    DOM: E,
                    time: new Date().getTime(),
                    width: E.width,
                    obj: E.obj,
                    readyState: E.readyState,
                    objectProperty: E.objectProperty
                };
                if (s && s.parentNode) {
                    E.setStyle(D, E.getStyle.span());
                    s.appendChild(D);
                    try {
                        D.innerHTML = G
                    } catch (z) {
                    }
                    F.span = D;
                    F.winLoaded = j.win.loaded
                }
                D = 0;
                s = 0;
                B = 0;
                E.HTML.push(F);
                return F
            }
        },
        Plugins: {}
    };
    j.init.library();
    var c = {
        setPluginStatus: function () {
            var t = this, q = t.nav.detected, p = t.nav.version, v = p, r = q > 0;
            var u = t.axo.detected, s = t.axo.version, x = t.doc.detected, w = t.doc.version;
            v = v || s || w;
            r = r || u > 0 || x > 0;
            v = v || null;
            t.version = j.formatNum(v);
            r = v ? 1 : (r ? 0 : -1);
            if (r == -1) {
                r = u == -0.5 || x == -0.5 ? -0.15 : (j.browser.isIE && (!j.browser.ActiveXEnabled || j.browser.ActiveXFilteringEnabled) ? -1.5 : -1)
            }
            t.installed = r;
        },
        getVersion: function () {
            var p = this, q = 0;
            if ((!q || j.dbug) && p.nav.query().version) {
                q = 1
            }
            if ((!q || j.dbug) && p.axo.query().version) {
                q = 1
            }
            if ((!q || j.dbug) && p.doc.query().version) {
                q = 1
            }
            p.setPluginStatus()
        },
        nav: {
            detected: 0,
            version: null,
            mimeType: ["application/pdf", "application/vnd.adobe.pdfxml"],
            find: "Adobe.*PDF.*Plug-?in|Adobe.*Acrobat.*Plug-?in|Adobe.*Reader.*Plug-?in",
            plugins: ["Adobe Acrobat", "Adobe Acrobat and Reader Plug-in", "Adobe Reader Plugin"],
            query: function () {
                var r = this, q, p = null;
                if (r.detected || !j.hasMimeType(r.mimeType)) {
                    return r
                }
                q = j.pd.findNavPlugin({find: r.find, mimes: r.mimeType, plugins: r.plugins});
                r.detected = q ? 1 : -1;
                if (q) {
                    p = j.getNum(q.description) || j.getNum(q.name);
                    p = j.getPluginFileVersion(q, p);
                    if (!p) {
                        p = r.attempt3()
                    }
                    if (p) {
                        r.version = p
                    }
                }
                return r
            },
            attempt3: function () {
                var p = null;
                if (j.OS == 1) {
                    if (j.hasMimeType("application/vnd.adobe.pdfxml")) {
                        p = "9"
                    } else {
                        if (j.hasMimeType("application/vnd.adobe.x-mars")) {
                            p = "8"
                        } else {
                            if (j.hasMimeType("application/vnd.adobe.xfdf")) {
                                p = "6"
                            }
                        }
                    }
                }
                return p
            }
        },
        activexQuery: function (w) {
            var u = "", q = null, t, p, s, r;
            try {
                if (w) {
                    u = w.GetVersions();
                }
            } catch (v) {
            }
            if (u && j.isString(u)) {
                t = /\=\s*[\d\.]+/g;
                r = u.match(t);
                if (r) {
                    for (p = 0; p < r.length; p++) {
                        s = j.formatNum(j.getNum(r[p]));
                        if (s && (!q || j.compareNums(s, q) > 0)) {
                            q = s
                        }
                    }
                }
            }
            return q
        },
        axo: {
            detected: 0,
            version: null,
            progID: ["AcroPDF.PDF", "AcroPDF.PDF.1", "PDF.PdfCtrl", "PDF.PdfCtrl.5", "PDF.PdfCtrl.1"],
            progID_dummy: "AcroDUMMY.DUMMY",
            query: function () {
                var s = this, q = c, t, r = null, p, u;
                if (s.detected) {
                    return s
                }
                s.detected = -1;
                t = j.getAXO(s.progID_dummy);
                if (!t) {
                    u = j.errObj
                }
                for (p = 0; p < s.progID.length; p++) {
                    t = j.getAXO(s.progID[p]);
                    if (t) {
                        s.detected = 1;
                        r = q.activexQuery(t);
                        if (!j.dbug && r) {
                            break
                        }
                    } else {
                        if (u && j.errObj && u !== j.errObj && u.message !== j.errObj.message) {
                            s.detected = -0.5
                        }
                    }
                }
                if (r) {
                    s.version = r
                }
                return s
            }
        },
        doc: {
            detected: 0,
            version: null,
            classID: "clsid:CA8A9780-280D-11CF-A24D-444553540000",
            classID_dummy: "clsid:CA8A9780-280D-11CF-A24D-BA9876543210",
            DummySpanTagHTML: 0,
            HTML: 0,
            DummyObjTagHTML1: 0,
            DummyObjTagHTML2: 0,
            isDisabled: function () {
                var q = this, p = 0;
                if (q.HTML) {
                    p = 1
                } else {
                    if (j.dbug) {
                    } else {
                        if (!j.DOM.isEnabled.objectTagUsingActiveX()) {
                            p = 1
                        }
                    }
                }
                return p
            },
            query: function () {
                var u = this, p = c, q = null, r = j.DOM.altHTML, s = 1, t = 1, v;
                if (u.isDisabled()) {
                    return u
                }
                if (!u.DummySpanTagHTML) {
                    u.DummySpanTagHTML = j.DOM.insert("", [], [], r, p, t)
                }
                if (!u.HTML) {
                    u.HTML = j.DOM.insert("object", ["classid", u.classID], [], r, p, t)
                }
                if (!u.DummyObjTagHTML2) {
                    u.DummyObjTagHTML2 = j.DOM.insert("object", ["classid", u.classID_dummy], [], r, p, t)
                }
                v = j.DOM.getTagStatus(u.HTML, u.DummySpanTagHTML, u.DummyObjTagHTML1, u.DummyObjTagHTML2, 0, 0, s);
                q = p.activexQuery(u.HTML.obj());
                u.detected = v > 0 || q ? 1 : (v == -0.1 || v == -0.5 ? -0.5 : -1);
                u.version = q ? q : null;
                return u
            }
        }
    };
    j.addPlugin("adobereader", c);
})();