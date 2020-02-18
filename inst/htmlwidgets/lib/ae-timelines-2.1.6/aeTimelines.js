(function(global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined'
        ? (module.exports = factory(require('d3'), require('webcharts')))
        : typeof define === 'function' && define.amd
          ? define(['d3', 'webcharts'], factory)
          : (global.aeTimelines = factory(global.d3, global.webCharts));
})(this, function(d3, webcharts) {
    'use strict';

    if (typeof Object.assign != 'function') {
        Object.defineProperty(Object, 'assign', {
            value: function assign(target, varArgs) {
                if (target == null) {
                    // TypeError if undefined or null
                    throw new TypeError('Cannot convert undefined or null to object');
                }

                var to = Object(target);

                for (var index = 1; index < arguments.length; index++) {
                    var nextSource = arguments[index];

                    if (nextSource != null) {
                        // Skip over if undefined or null
                        for (var nextKey in nextSource) {
                            // Avoid bugs when hasOwnProperty is shadowed
                            if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
                                to[nextKey] = nextSource[nextKey];
                            }
                        }
                    }
                }

                return to;
            },
            writable: true,
            configurable: true
        });
    }

    if (!Array.prototype.find) {
        Object.defineProperty(Array.prototype, 'find', {
            value: function value(predicate) {
                // 1. Let O be ? ToObject(this value).
                if (this == null) {
                    throw new TypeError('"this" is null or not defined');
                }

                var o = Object(this);

                // 2. Let len be ? ToLength(? Get(O, 'length')).
                var len = o.length >>> 0;

                // 3. If IsCallable(predicate) is false, throw a TypeError exception.
                if (typeof predicate !== 'function') {
                    throw new TypeError('predicate must be a function');
                }

                // 4. If thisArg was supplied, let T be thisArg; else let T be undefined.
                var thisArg = arguments[1];

                // 5. Let k be 0.
                var k = 0;

                // 6. Repeat, while k < len
                while (k < len) {
                    // a. Let Pk be ! ToString(k).
                    // b. Let kValue be ? Get(O, Pk).
                    // c. Let testResult be ToBoolean(? Call(predicate, T, � kValue, k, O �)).
                    // d. If testResult is true, return kValue.
                    var kValue = o[k];
                    if (predicate.call(thisArg, kValue, k, o)) {
                        return kValue;
                    }
                    // e. Increase k by 1.
                    k++;
                }

                // 7. Return undefined.
                return undefined;
            }
        });
    }

    if (!Array.prototype.findIndex) {
        Object.defineProperty(Array.prototype, 'findIndex', {
            value: function value(predicate) {
                // 1. Let O be ? ToObject(this value).
                if (this == null) {
                    throw new TypeError('"this" is null or not defined');
                }

                var o = Object(this);

                // 2. Let len be ? ToLength(? Get(O, "length")).
                var len = o.length >>> 0;

                // 3. If IsCallable(predicate) is false, throw a TypeError exception.
                if (typeof predicate !== 'function') {
                    throw new TypeError('predicate must be a function');
                }

                // 4. If thisArg was supplied, let T be thisArg; else let T be undefined.
                var thisArg = arguments[1];

                // 5. Let k be 0.
                var k = 0;

                // 6. Repeat, while k < len
                while (k < len) {
                    // a. Let Pk be ! ToString(k).
                    // b. Let kValue be ? Get(O, Pk).
                    // c. Let testResult be ToBoolean(? Call(predicate, T, � kValue, k, O �)).
                    // d. If testResult is true, return k.
                    var kValue = o[k];
                    if (predicate.call(thisArg, kValue, k, o)) {
                        return k;
                    }
                    // e. Increase k by 1.
                    k++;
                }

                // 7. Return -1.
                return -1;
            }
        });
    }

    var _typeof =
        typeof Symbol === 'function' && typeof Symbol.iterator === 'symbol'
            ? function(obj) {
                  return typeof obj;
              }
            : function(obj) {
                  return obj &&
                      typeof Symbol === 'function' &&
                      obj.constructor === Symbol &&
                      obj !== Symbol.prototype
                      ? 'symbol'
                      : typeof obj;
              };

    /*------------------------------------------------------------------------------------------------\
      Clone a variable (http://stackoverflow.com/a/728694).
    \------------------------------------------------------------------------------------------------*/

    function clone(obj) {
        var copy;

        //Handle the 3 simple types, and null or undefined
        if (null == obj || 'object' != (typeof obj === 'undefined' ? 'undefined' : _typeof(obj)))
            return obj;

        //Handle Date
        if (obj instanceof Date) {
            copy = new Date();
            copy.setTime(obj.getTime());
            return copy;
        }

        //Handle Array
        if (obj instanceof Array) {
            copy = [];
            for (var i = 0, len = obj.length; i < len; i++) {
                copy[i] = clone(obj[i]);
            }
            return copy;
        }

        //Handle Object
        if (obj instanceof Object) {
            copy = {};
            for (var attr in obj) {
                if (obj.hasOwnProperty(attr)) copy[attr] = clone(obj[attr]);
            }
            return copy;
        }

        throw new Error("Unable to copy obj! Its type isn't supported.");
    }

    var isMergeableObject = function isMergeableObject(value) {
        return isNonNullObject(value) && !isSpecial(value);
    };

    function isNonNullObject(value) {
        return (
            !!value && (typeof value === 'undefined' ? 'undefined' : _typeof(value)) === 'object'
        );
    }

    function isSpecial(value) {
        var stringValue = Object.prototype.toString.call(value);

        return (
            stringValue === '[object RegExp]' ||
            stringValue === '[object Date]' ||
            isReactElement(value)
        );
    }

    // see https://github.com/facebook/react/blob/b5ac963fb791d1298e7f396236383bc955f916c1/src/isomorphic/classic/element/ReactElement.js#L21-L25
    var canUseSymbol = typeof Symbol === 'function' && Symbol.for;
    var REACT_ELEMENT_TYPE = canUseSymbol ? Symbol.for('react.element') : 0xeac7;

    function isReactElement(value) {
        return value.$$typeof === REACT_ELEMENT_TYPE;
    }

    function emptyTarget(val) {
        return Array.isArray(val) ? [] : {};
    }

    function cloneUnlessOtherwiseSpecified(value, options) {
        return options.clone !== false && options.isMergeableObject(value)
            ? deepmerge(emptyTarget(value), value, options)
            : value;
    }

    function defaultArrayMerge(target, source, options) {
        return target.concat(source).map(function(element) {
            return cloneUnlessOtherwiseSpecified(element, options);
        });
    }

    function mergeObject(target, source, options) {
        var destination = {};

        if (options.isMergeableObject(target)) {
            Object.keys(target).forEach(function(key) {
                destination[key] = cloneUnlessOtherwiseSpecified(target[key], options);
            });
        }

        Object.keys(source).forEach(function(key) {
            if (!options.isMergeableObject(source[key]) || !target[key]) {
                destination[key] = cloneUnlessOtherwiseSpecified(source[key], options);
            } else {
                destination[key] = deepmerge(target[key], source[key], options);
            }
        });

        return destination;
    }

    function deepmerge(target, source, options) {
        options = options || {};

        options.arrayMerge = options.arrayMerge || defaultArrayMerge;

        options.isMergeableObject = options.isMergeableObject || isMergeableObject;

        var sourceIsArray = Array.isArray(source);

        var targetIsArray = Array.isArray(target);

        var sourceAndTargetTypesMatch = sourceIsArray === targetIsArray;

        if (!sourceAndTargetTypesMatch) {
            return cloneUnlessOtherwiseSpecified(source, options);
        } else if (sourceIsArray) {
            return options.arrayMerge(target, source, options);
        } else {
            return mergeObject(target, source, options);
        }
    }

    deepmerge.all = function deepmergeAll(array, options) {
        if (!Array.isArray(array)) {
            throw new Error('first argument should be an array');
        }

        return array.reduce(function(prev, next) {
            return deepmerge(prev, next, options);
        }, {});
    };

    var deepmerge_1 = deepmerge;

    var rendererSpecificSettings = {
        id_col: 'USUBJID',
        seq_col: 'AESEQ',
        stdy_col: 'ASTDY',
        endy_col: 'AENDY',
        term_col: 'AETERM',

        color: {
            value_col: 'AESEV',
            label: 'Severity/Intensity',
            values: ['MILD', 'MODERATE', 'SEVERE'],
            colors: [
                '#66bd63', // mild
                '#fdae61', // moderate
                '#d73027', // severe
                '#377eb8',
                '#984ea3',
                '#ff7f00',
                '#a65628',
                '#f781bf'
            ]
        },

        highlight: {
            value_col: 'AESER',
            label: 'Serious Event',
            value: 'Y',
            detail_col: null,
            attributes: {
                stroke: 'black',
                'stroke-width': '2',
                fill: 'none'
            }
        },

        filters: null,
        details: null,
        custom_marks: null
    };

    var webchartsSettings = {
        x: {
            column: 'wc_value',
            type: 'linear',
            label: null
        },
        y: {
            column: null, // set in syncSettings()
            type: 'ordinal',
            label: '',
            sort: 'earliest',
            behavior: 'flex'
        },
        marks: [
            {
                type: 'line',
                per: null, // set in syncSettings()
                tooltip: null, // set in syncSettings()
                attributes: {
                    'stroke-width': 5,
                    'stroke-opacity': 0.5
                }
            },
            {
                type: 'circle',
                per: null, // set in syncSettings()
                tooltip: null, // set in syncSettings()
                attributes: {
                    'fill-opacity': 0.5,
                    'stroke-opacity': 0.5
                }
            }
        ],
        legend: { location: 'top', mark: 'circle' },
        gridlines: 'y',
        range_band: 15,
        margin: { top: 50 }, // for second x-axis
        resizable: true
    };

    var defaultSettings = Object.assign({}, rendererSpecificSettings, webchartsSettings);

    function syncSettings(preSettings) {
        var nextSettings = clone(preSettings);

        nextSettings.y.column = nextSettings.id_col;

        //Lines (AE duration)
        nextSettings.marks[0].per = [nextSettings.id_col, nextSettings.seq_col];
        nextSettings.marks[0].tooltip =
            'Reported Term: [' +
            nextSettings.term_col +
            ']' +
            ('\nStart Day: [' + nextSettings.stdy_col + ']') +
            ('\nStop Day: [' + nextSettings.endy_col + ']');

        //Circles (AE start day)
        nextSettings.marks[1].per = [nextSettings.id_col, nextSettings.seq_col, 'wc_value'];
        nextSettings.marks[1].tooltip =
            'Reported Term: [' +
            nextSettings.term_col +
            ']' +
            ('\nStart Day: [' + nextSettings.stdy_col + ']') +
            ('\nStop Day: [' + nextSettings.endy_col + ']');
        nextSettings.marks[1].values = { wc_category: [nextSettings.stdy_col] };

        //Define highlight marks.
        if (nextSettings.highlight) {
            //Lines (highlighted event duration)
            var highlightLine = {
                type: 'line',
                per: [nextSettings.id_col, nextSettings.seq_col],
                tooltip:
                    'Reported Term: [' +
                    nextSettings.term_col +
                    ']' +
                    ('\nStart Day: [' + nextSettings.stdy_col + ']') +
                    ('\nStop Day: [' + nextSettings.endy_col + ']') +
                    ('\n' +
                        nextSettings.highlight.label +
                        ': [' +
                        (nextSettings.highlight.detail_col
                            ? nextSettings.highlight.detail_col
                            : nextSettings.highlight.value_col) +
                        ']'),
                values: {},
                attributes: nextSettings.highlight.attributes || {}
            };
            highlightLine.values[nextSettings.highlight.value_col] = nextSettings.highlight.value;
            highlightLine.attributes.class = 'highlight';
            nextSettings.marks.push(highlightLine);

            //Circles (highlighted event start day)
            var highlightCircle = {
                type: 'circle',
                per: [nextSettings.id_col, nextSettings.seq_col, 'wc_value'],
                tooltip:
                    'Reported Term: [' +
                    nextSettings.term_col +
                    ']' +
                    ('\nStart Day: [' + nextSettings.stdy_col + ']') +
                    ('\nStop Day: [' + nextSettings.endy_col + ']') +
                    ('\n' +
                        nextSettings.highlight.label +
                        ': [' +
                        (nextSettings.highlight.detail_col
                            ? nextSettings.highlight.detail_col
                            : nextSettings.highlight.value_col) +
                        ']'),
                values: { wc_category: nextSettings.stdy_col },
                attributes: nextSettings.highlight.attributes || {}
            };
            highlightCircle.values[nextSettings.highlight.value_col] = nextSettings.highlight.value;
            highlightCircle.attributes.class = 'highlight';
            nextSettings.marks.push(highlightCircle);
        }

        //Define mark coloring and legend.
        nextSettings.color_by = nextSettings.color.value_col;
        nextSettings.colors = nextSettings.color.colors;
        nextSettings.legend = nextSettings.legend || { location: 'top' };
        nextSettings.legend.label = nextSettings.color.label;
        nextSettings.legend.order = nextSettings.color.values;
        nextSettings.color_dom = nextSettings.color.values;

        //Default filters
        if (!nextSettings.filters || nextSettings.filters.length === 0) {
            nextSettings.filters = [
                { value_col: nextSettings.color.value_col, label: nextSettings.color.label },
                { value_col: nextSettings.id_col, label: 'Participant Identifier' }
            ];
            if (nextSettings.highlight)
                nextSettings.filters.unshift({
                    value_col: nextSettings.highlight.value_col,
                    label: nextSettings.highlight.label
                });
        }

        //Default detail listing columns
        var defaultDetails = [
            { value_col: nextSettings.seq_col, label: 'Sequence Number' },
            { value_col: nextSettings.stdy_col, label: 'Start Day' },
            { value_col: nextSettings.endy_col, label: 'Stop Day' },
            { value_col: nextSettings.term_col, label: 'Reported Term' }
        ];

        //Add settings.color.value_col to default details.
        defaultDetails.push({
            value_col: nextSettings.color.value_col,
            label: nextSettings.color.label
        });

        //Add settings.highlight.value_col and settings.highlight.detail_col to default details.
        if (nextSettings.highlight) {
            defaultDetails.push({
                value_col: nextSettings.highlight.value_col,
                label: nextSettings.highlight.label
            });

            if (nextSettings.highlight.detail_col)
                defaultDetails.push({
                    value_col: nextSettings.highlight.detail_col,
                    label: nextSettings.highlight.label + ' Details'
                });
        }

        //Add settings.filters columns to default details.
        nextSettings.filters.forEach(function(filter) {
            if (filter !== nextSettings.id_col && filter.value_col !== nextSettings.id_col)
                defaultDetails.push({
                    value_col: filter.value_col,
                    label: filter.label
                });
        });

        //Redefine settings.details with defaults.
        if (!nextSettings.details) nextSettings.details = defaultDetails;
        else {
            //Allow user to specify an array of columns or an array of objects with a column property
            //and optionally a column label.
            nextSettings.details = nextSettings.details.map(function(d) {
                return {
                    value_col: d.value_col ? d.value_col : d,
                    label: d.label ? d.label : d.value_col ? d.value_col : d
                };
            });

            //Add default details to settings.details.
            defaultDetails.reverse().forEach(function(defaultDetail) {
                return nextSettings.details.unshift(defaultDetail);
            });
        }

        //Add custom marks to marks array.
        if (nextSettings.custom_marks)
            nextSettings.custom_marks.forEach(function(custom_mark) {
                custom_mark.attributes = custom_mark.attributes || {};
                custom_mark.attributes.class = 'custom';
                nextSettings.marks.push(custom_mark);
            });

        return nextSettings;
    }

    var controlInputs = [
        {
            type: 'dropdown',
            option: 'y.sort',
            label: 'Sort Participant IDs',
            values: ['earliest', 'alphabetical-descending'],
            require: true
        }
    ];

    function syncControlInputs(preControlInputs, preSettings) {
        preSettings.filters.forEach(function(d, i) {
            var thisFilter = {
                type: 'subsetter',
                value_col: d.value_col ? d.value_col : d,
                label: d.label ? d.label : d.value_col ? d.value_col : d
            };
            //add the filter to the control inputs (as long as it isn't already there)
            var current_value_cols = preControlInputs
                .filter(function(f) {
                    return f.type == 'subsetter';
                })
                .map(function(m) {
                    return m.value_col;
                });
            if (current_value_cols.indexOf(thisFilter.value_col) == -1)
                preControlInputs.unshift(thisFilter);
        });

        return preControlInputs;
    }

    function syncSecondSettings(preSettings) {
        var nextSettings = clone(preSettings);

        nextSettings.y.column = nextSettings.seq_col;
        nextSettings.y.sort = 'alphabetical-descending';

        nextSettings.marks[0].per = [nextSettings.seq_col];
        nextSettings.marks[1].per = [nextSettings.seq_col, 'wc_value'];

        if (nextSettings.highlight) {
            nextSettings.marks[2].per = [nextSettings.seq_col];
            nextSettings.marks[3].per = [nextSettings.seq_col, 'wc_value'];
        }

        nextSettings.range_band = preSettings.range_band * 2;
        nextSettings.margin = null;
        nextSettings.transitions = false;

        return nextSettings;
    }

    function calculatePopulationSize() {
        var _this = this;

        this.populationCount = d3
            .set(
                this.raw_data.map(function(d) {
                    return d[_this.config.id_col];
                })
            )
            .values().length;
    }

    function cleanData() {
        var _this = this;

        this.superRaw = this.raw_data;
        var N = this.superRaw.length;

        //Remove records with empty verbatim terms.
        this.superRaw = this.superRaw.filter(function(d) {
            return /[^\s*$]/.test(d[_this.config.term_col]);
        });
        var n1 = this.superRaw.length;
        var diff1 = N - n1;
        if (diff1)
            console.warn(diff1 + ' records without [ ' + this.config.term_col + ' ] removed.');

        //Remove records with non-integer start days.
        this.superRaw = this.superRaw.filter(function(d) {
            return /^-?\d+$/.test(d[_this.config.stdy_col]);
        });
        var n2 = this.superRaw.length;
        var diff2 = n1 - n2;
        if (diff2)
            console.warn(diff2 + ' records without [ ' + this.config.stdy_col + ' ] removed.');
    }

    function checkFilters() {
        var _this = this;

        this.controls.config.inputs = this.controls.config.inputs.filter(function(input) {
            if (input.type !== 'subsetter') return true;
            else {
                var levels = d3
                    .set(
                        _this.superRaw.map(function(d) {
                            return d[input.value_col];
                        })
                    )
                    .values();
                if (levels.length < 2) {
                    console.warn(
                        'The [ ' +
                            input.value_col +
                            ' ] filter was removed because the variable has only one level.'
                    );
                    return false;
                }

                return true;
            }
        });
    }

    function checkColorBy() {
        var _this = this;

        this.superRaw.forEach(function(d) {
            return (d[_this.config.color_by] = /[^\s*$]/.test(d[_this.config.color_by])
                ? d[_this.config.color_by]
                : 'N/A');
        });

        //Flag NAs
        if (
            this.superRaw.some(function(d) {
                return d[_this.config.color_by] === 'N/A';
            })
        )
            this.na = true;
    }

    function defineColorDomain() {
        var _this = this;

        var color_by_values = d3
            .set(
                this.superRaw.map(function(d) {
                    return d[_this.config.color_by];
                })
            )
            .values()
            .sort(function(a, b) {
                var aIndex = _this.config.color.values.indexOf(a);
                var bIndex = _this.config.color.values.indexOf(b);
                var diff = aIndex > -1 && bIndex > -1 ? aIndex - bIndex : 0;

                return diff
                    ? diff
                    : aIndex > -1
                      ? -1
                      : bIndex > -1
                        ? 1
                        : a === 'N/A'
                          ? 1
                          : b === 'N/A' ? -1 : a.toLowerCase() < b.toLowerCase() ? -1 : 1;
            });
        color_by_values.forEach(function(color_by_value, i) {
            if (_this.config.color.values.indexOf(color_by_value) < 0) {
                _this.config.color_dom.push(color_by_value);
                _this.config.legend.order.push(color_by_value);
                _this.chart2.config.color_dom.push(color_by_value);
                _this.chart2.config.legend.order.push(color_by_value);
            }
        });
    }

    /*------------------------------------------------------------------------------------------------\
      Expand a data array to one item per original item per specified column.
    \------------------------------------------------------------------------------------------------*/

    function lengthenRaw() {
        var data = this.superRaw;
        var columns = [this.config.stdy_col, this.config.endy_col];
        var my_data = [];

        data.forEach(function(d) {
            columns.forEach(function(column) {
                var obj = Object.assign({}, d);
                obj.wc_category = column;
                obj.wc_value = parseFloat(d[column]);
                my_data.push(obj);
            });
        });

        this.raw_data = my_data;
    }

    function initCustomEvents() {
        var chart = this;
        chart.participantsSelected = [];
        chart.events.participantsSelected = new CustomEvent('participantsSelected');
    }

    function onInit() {
        calculatePopulationSize.call(this);
        cleanData.call(this);
        checkFilters.call(this);
        checkColorBy.call(this);
        defineColorDomain.call(this);
        lengthenRaw.call(this);
        initCustomEvents.call(this);
    }

    function sortLegendFilter() {
        var _this = this;

        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(d) {
                return d.value_col === _this.config.color.value_col;
            })
            .selectAll('option')
            .sort(function(a, b) {
                return _this.config.legend.order.indexOf(a) - _this.config.legend.order.indexOf(b);
            });
    }

    function addParticipantCountContainer() {
        this.wrap
            .select('.legend')
            .append('span')
            .classed('annote', true)
            .style('float', 'right')
            .style('font-style', 'italic');
    }

    function addTopXaxis() {
        this.svg
            .append('g')
            .attr('class', 'x2 axis linear')
            .append('text')
            .attr({
                class: 'axis-title top',
                dy: '2em',
                'text-anchor': 'middle'
            })
            .text(this.config.x_label);
    }

    function addBackButton() {
        var _this = this;

        this.chart2.wrap
            .insert('div', ':first-child')
            .attr('id', 'backButton')
            .insert('button', '.legend')
            .html('&#8592; Back')
            .style('cursor', 'pointer')
            .on('click', function() {
                //Trigger participantsSelected event
                _this.participantsSelected = [];
                _this.events.participantsSelected.data = _this.participantsSelected;
                _this.wrap.node().dispatchEvent(_this.events.participantsSelected);

                //remove the details chart
                _this.chart2.wrap.select('.id-title').remove();
                _this.chart2.wrap.style('display', 'none');
                _this.table.wrap.style('display', 'none');
                _this.controls.wrap.style('display', 'block');
                _this.wrap.style('display', 'block');
                _this.draw();
            });
    }

    function onLayout() {
        sortLegendFilter.call(this);
        addParticipantCountContainer.call(this);
        addTopXaxis.call(this);
        addBackButton.call(this);
    }

    function onPreprocess() {}

    function onDatatransform() {}

    function addNAToColorScale() {
        if (this.na)
            // defined in ../onInit/checkColorBy
            this.colorScale.range().splice(this.colorScale.domain().indexOf('N/A'), 1, '#999999');
    }

    /*------------------------------------------------------------------------------------------------\
      Annotate number of participants based on current filters, number of participants in all, and
      the corresponding percentage.

      Inputs:

        chart - a webcharts chart object
        id_unit - a text string to label the units in the annotation (default = 'participants')
        selector - css selector for the annotation
    \------------------------------------------------------------------------------------------------*/

    function updateParticipantCount(chart, selector, id_unit) {
        //count the number of unique ids in the current chart and calculate the percentage
        var filtered_data = chart.raw_data.filter(function(d) {
            var filtered = d[chart.config.seq_col] === '';
            chart.filters.forEach(function(di) {
                if (filtered === false && di.val !== 'All')
                    filtered =
                        Object.prototype.toString.call(di.val) === '[object Array]'
                            ? di.val.indexOf(d[di.col]) === -1
                            : di.val !== d[di.col];
            });
            return !filtered;
        });
        var currentObs = d3
            .set(
                filtered_data.map(function(d) {
                    return d[chart.config.id_col];
                })
            )
            .values().length;

        var percentage = d3.format('0.1%')(currentObs / chart.populationCount);

        //clear the annotation
        var annotation = d3.select(selector);
        annotation.selectAll('*').remove();

        //update the annotation
        var units = id_unit ? ' ' + id_unit : ' participant(s)';
        annotation.text(
            currentObs + ' of ' + chart.populationCount + units + ' shown (' + percentage + ')'
        );
    }

    function sortYdomain() {
        var _this = this;

        var yAxisSort = this.controls.wrap
            .selectAll('.control-group')
            .filter(function(d) {
                return d.option && d.option === 'y.sort';
            })
            .select('option:checked')
            .text();

        if (yAxisSort === 'earliest') {
            //Redefine filtered data as it defaults to the final mark drawn, which might be filtered in
            //addition to the current filter selections.
            var filtered_data = this.raw_data.filter(function(d) {
                var filtered = d[_this.config.seq_col] === '';
                _this.filters.forEach(function(di) {
                    if (filtered === false && di.val !== 'All')
                        filtered =
                            Object.prototype.toString.call(di.val) === '[object Array]'
                                ? di.val.indexOf(d[di.col]) === -1
                                : di.val !== d[di.col];
                });
                return !filtered;
            });

            //Capture all participant IDs with adverse events with a start day.
            var withStartDay = d3
                .nest()
                .key(function(d) {
                    return d[_this.config.id_col];
                })
                .rollup(function(d) {
                    return d3.min(d, function(di) {
                        return +di[_this.config.stdy_col];
                    });
                })
                .entries(
                    filtered_data.filter(function(d) {
                        return (
                            !isNaN(parseFloat(d[_this.config.stdy_col])) &&
                            isFinite(d[_this.config.stdy_col])
                        );
                    })
                )
                .sort(function(a, b) {
                    return a.values > b.values
                        ? -2
                        : a.values < b.values ? 2 : a.key > b.key ? -1 : 1;
                })
                .map(function(d) {
                    return d.key;
                });

            //Capture all participant IDs with adverse events without a start day.
            var withoutStartDay = d3
                .set(
                    filtered_data
                        .filter(function(d) {
                            return (
                                +d[_this.config.seq_col] > 0 &&
                                (isNaN(parseFloat(d[_this.config.stdy_col])) ||
                                    !isFinite(d[_this.config.stdy_col])) &&
                                withStartDay.indexOf(d[_this.config.id_col]) === -1
                            );
                        })
                        .map(function(d) {
                            return d[_this.config.id_col];
                        })
                )
                .values();
            this.y_dom = withStartDay.concat(withoutStartDay);
        } else this.y_dom = this.y_dom.sort(d3.descending);
    }

    function onDraw() {
        addNAToColorScale.call(this);
        updateParticipantCount(this, '.annote', 'participant ID(s)');
        sortYdomain.call(this);
    }

    /*------------------------------------------------------------------------------------------------\
      Add highlighted adverse event legend item.
    \------------------------------------------------------------------------------------------------*/

    function addHighlightLegendItem(chart) {
        chart.wrap.select('.legend li.highlight').remove();
        var highlightLegendItem = chart.wrap
            .select('.legend')
            .append('li')
            .attr('class', 'highlight')
            .style({
                'list-style-type': 'none',
                'margin-right': '1em',
                display: 'inline-block'
            });
        var highlightLegendColorBlock = highlightLegendItem
            .append('svg')
            .attr({
                width: '1.75em',
                height: '1.5em'
            })
            .style({
                position: 'relative',
                top: '0.35em'
            });
        highlightLegendColorBlock
            .append('circle')
            .attr({
                cx: 10,
                cy: 10,
                r: 4
            })
            .style(chart.config.highlight.attributes);
        highlightLegendColorBlock
            .append('line')
            .attr({
                x1: 2 * 3.14 * 4 - 10,
                y1: 10,
                x2: 2 * 3.14 * 4 - 5,
                y2: 10
            })
            .style(chart.config.highlight.attributes)
            .style('shape-rendering', 'crispEdges');
        highlightLegendItem
            .append('text')
            .style('margin-left', '.35em')
            .text(chart.config.highlight.label);
    }

    function drawTopXaxis() {
        var x2Axis = d3.svg
            .axis()
            .scale(this.x)
            .orient('top')
            .tickFormat(this.xAxis.tickFormat())
            .innerTickSize(this.xAxis.innerTickSize())
            .outerTickSize(this.xAxis.outerTickSize())
            .ticks(this.xAxis.ticks()[0]);
        var g_x2_axis = this.svg.select('g.x2.axis').attr('class', 'x2 axis linear');
        g_x2_axis.call(x2Axis);
        g_x2_axis
            .select('text.axis-title.top')
            .attr(
                'transform',
                'translate(' + this.raw_width / 2 + ',-' + this.config.margin.top + ')'
            );
        g_x2_axis.select('.domain').attr({
            fill: 'none',
            stroke: '#ccc',
            'shape-rendering': 'crispEdges'
        });
        g_x2_axis.selectAll('.tick line').attr('stroke', '#eee');
    }

    function addTickClick() {
        var _this = this;

        var context = this;
        this.svg
            .select('.y.axis')
            .selectAll('.tick')
            .style('cursor', 'pointer')
            .on('click', function(d) {
                var csv2 = _this.raw_data.filter(function(di) {
                    return di[_this.config.id_col] === d;
                });
                _this.chart2.wrap.style('display', 'block');
                _this.chart2.draw(csv2);
                _this.chart2.wrap
                    .select('#backButton')
                    .append('strong')
                    .attr('class', 'id-title')
                    .style('margin-left', '1%')
                    .text('Participant: ' + d);

                //Trigger participantsSelected event
                context.participantsSelected = [d];
                context.events.participantsSelected.data = context.participantsSelected;
                context.wrap.node().dispatchEvent(context.events.participantsSelected);

                //Sort listing by sequence.
                var seq_col = context.config.seq_col;
                var tableData = _this.superRaw
                    .filter(function(di) {
                        return di[_this.config.id_col] === d;
                    })
                    .sort(function(a, b) {
                        return +a[seq_col] < b[seq_col] ? -1 : 1;
                    });

                //Define listing columns.
                _this.table.config.cols = d3
                    .set(
                        _this.config.details.map(function(detail) {
                            return detail.value_col;
                        })
                    )
                    .values();
                _this.table.config.headers = d3
                    .set(
                        _this.config.details.map(function(detail) {
                            return detail.label;
                        })
                    )
                    .values();
                _this.table.wrap.style('display', 'block');
                _this.table.draw(tableData);
                _this.table.wrap.selectAll('th,td').style({
                    'text-align': 'left',
                    'padding-right': '10px'
                });

                //Hide timelines.
                _this.wrap.style('display', 'none');
                _this.controls.wrap.style('display', 'none');
            });
    }

    function onResize() {
        var context = this;

        //Add highlight adverse event legend item.
        if (this.config.highlight) addHighlightLegendItem(this);

        //Draw second x-axis at top of chart.
        drawTopXaxis.call(this);

        //Draw second chart when y-axis tick label is clicked.
        addTickClick.call(this);

        /**-------------------------------------------------------------------------------------------\
          Second chart callbacks.
        \-------------------------------------------------------------------------------------------**/

        this.chart2.on('preprocess', function() {
            //Define color scale.
            this.config.color_dom = context.colorScale.domain();
        });

        this.chart2.on('draw', function() {
            //Sync x-axis domain of second chart with that of the original chart.
            this.x_dom = context.x_dom;
        });

        this.chart2.on('resize', function() {
            //Add highlight adverse event legend item.
            if (this.config.highlight) addHighlightLegendItem(this);
        });
    }

    // utilities

    function aeTimelines() {
        var element = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'body';
        var settings = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

        //Merge default settings with custom settings.
        var mergedSettings = deepmerge_1(defaultSettings, settings, {
            arrayMerge: function arrayMerge(destination, source) {
                return source;
            }
        });

        //Sync properties within settings object.
        var syncedSettings = syncSettings(mergedSettings);

        //Sync control inputs with settings object.
        var syncedControlInputs = syncControlInputs(controlInputs, syncedSettings);

        //Sync properties within secondary settings object.
        var syncedSecondSettings = syncSecondSettings(syncedSettings);

        //Create controls.
        var controls = webcharts.createControls(element, {
            location: 'top',
            inputs: syncedControlInputs
        });

        //Create chart.
        var chart = webcharts.createChart(element, syncedSettings, controls);
        chart.on('init', onInit);
        chart.on('layout', onLayout);
        chart.on('preprocess', onPreprocess);
        chart.on('datatransform', onDatatransform);
        chart.on('draw', onDraw);
        chart.on('resize', onResize);

        //Create participant-level chart.
        var chart2 = webcharts.createChart(element, syncedSecondSettings).init([]);
        chart2.wrap.style('display', 'none');
        chart.chart2 = chart2;

        //Create participant-level listing.
        var table = webcharts.createTable(element, {}).init([]);
        table.wrap.style('display', 'none');
        table.table.style('display', 'table');
        table.table.attr('width', '100%');
        chart.table = table;

        return chart;
    }

    return aeTimelines;
});
