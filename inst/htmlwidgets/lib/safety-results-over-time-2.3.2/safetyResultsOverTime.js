(function(global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined'
        ? (module.exports = factory(require('d3'), require('webcharts')))
        : typeof define === 'function' && define.amd
          ? define(['d3', 'webcharts'], factory)
          : ((global = global || self),
            (global.safetyResultsOverTime = factory(global.d3, global.webCharts)));
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

    Math.log10 =
        Math.log10 ||
        function(x) {
            return Math.log(x) * Math.LOG10E;
        };

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

    var hasOwnProperty = Object.prototype.hasOwnProperty;
    var propIsEnumerable = Object.prototype.propertyIsEnumerable;

    function toObject(val) {
        if (val === null || val === undefined) {
            throw new TypeError('Cannot convert undefined or null to object');
        }

        return Object(val);
    }

    function isObj(x) {
        var type = typeof x === 'undefined' ? 'undefined' : _typeof(x);
        return x !== null && (type === 'object' || type === 'function');
    }

    function assignKey(to, from, key) {
        var val = from[key];

        if (val === undefined) {
            return;
        }

        if (hasOwnProperty.call(to, key)) {
            if (to[key] === undefined) {
                throw new TypeError('Cannot convert undefined or null to object (' + key + ')');
            }
        }

        if (!hasOwnProperty.call(to, key) || !isObj(val)) to[key] = val;
        else if (val instanceof Array)
            to[key] = from[key]; // figure out how to merge arrays without converting them into objects
        else to[key] = assign(Object(to[key]), from[key]);
    }

    function assign(to, from) {
        if (to === from) {
            return to;
        }

        from = Object(from);

        for (var key in from) {
            if (hasOwnProperty.call(from, key)) {
                assignKey(to, from, key);
            }
        }

        if (Object.getOwnPropertySymbols) {
            var symbols = Object.getOwnPropertySymbols(from);

            for (var i = 0; i < symbols.length; i++) {
                if (propIsEnumerable.call(from, symbols[i])) {
                    assignKey(to, from, symbols[i]);
                }
            }
        }

        return to;
    }

    function merge(target) {
        target = toObject(target);

        for (var s = 1; s < arguments.length; s++) {
            assign(target, arguments[s]);
        }

        return target;
    }

    function rendererSettings() {
        return {
            id_col: 'USUBJID',
            time_settings: {
                value_col: 'VISIT',
                label: 'Visit',
                order_col: 'VISITNUM',
                order: null,
                rotate_tick_labels: true,
                vertical_space: 100
            },
            measure_col: 'TEST',
            value_col: 'STRESN',
            unit_col: 'STRESU',
            normal_col_low: 'STNRLO',
            normal_col_high: 'STNRHI',
            start_value: null,
            filters: null,
            groups: null,
            color_by: null,
            boxplots: true,
            outliers: true,
            violins: false,
            missingValues: ['', 'NA', 'N/A'],
            visits_without_data: false,
            unscheduled_visits: false,
            unscheduled_visit_pattern: '/unscheduled|early termination/i',
            unscheduled_visit_values: null // takes precedence over unscheduled_visit_pattern
        };
    }

    function webchartsSettings() {
        return {
            x: {
                column: null, // set in syncSettings()
                type: 'ordinal',
                label: null,
                behavior: 'flex',
                sort: 'alphabetical-ascending',
                tickAttr: null
            },
            y: {
                column: null, // set in syncSettings()
                type: 'linear',
                label: null,
                behavior: 'flex',
                stat: 'mean',
                format: null // set in ./onPreprocess/setYprecision()
            },
            marks: [
                {
                    type: 'line',
                    per: null, // set in syncSettings()
                    attributes: {
                        'stroke-width': 2,
                        'stroke-opacity': 1,
                        display: 'none'
                    }
                },
                {
                    type: 'circle',
                    per: null, // set in syncSettings()
                    attributes: {
                        stroke: 'black',
                        'stroke-opacity': 0,
                        'fill-opacity': 0
                    },
                    values: {
                        srot_outlier: [true]
                    },
                    radius: null, // set in syncSettings()
                    tooltip: null, // set in syncSettings()
                    hidden: true
                },
                {
                    type: 'circle',
                    per: null, // set in syncSettings()
                    attributes: {
                        stroke: 'black',
                        'stroke-opacity': 1,
                        'fill-opacity': 1
                    },
                    values: {
                        srot_outlier: [true]
                    },
                    radius: 1.75,
                    tooltip: null, // set in syncSettings()
                    hidden: false
                }
            ],
            legend: {
                mark: 'square'
            },
            color_by: null, // set in syncSettings()
            resizable: true,
            gridlines: 'y',
            aspect: 3
        };
    }

    function syncSettings(settings) {
        //x-axis
        settings.x.column = settings.time_settings.value_col;
        settings.x.label = settings.time_settings.label;
        settings.x.behavior = settings.visits_without_data ? 'raw' : 'flex';

        //y-axis
        settings.y.column = settings.value_col;

        //stratification
        var defaultGroup = { value_col: 'srot_none', label: 'None' };
        if (!(settings.groups instanceof Array && settings.groups.length))
            settings.groups = [defaultGroup];
        else
            settings.groups = [defaultGroup].concat(
                settings.groups.map(function(group) {
                    return {
                        value_col: group.value_col || group,
                        label: group.label || group.value_col || group
                    };
                })
            );

        //Remove duplicate values.
        settings.groups = d3
            .set(
                settings.groups.map(function(group) {
                    return group.value_col;
                })
            )
            .values()
            .map(function(value) {
                return {
                    value_col: value,
                    label: settings.groups.find(function(group) {
                        return group.value_col === value;
                    }).label
                };
            });

        //Set initial group-by variable.
        settings.color_by = settings.color_by
            ? settings.color_by
            : settings.groups.length > 1 ? settings.groups[1].value_col : defaultGroup.value_col;

        //Set initial group-by label.
        settings.legend.label = settings.groups.find(function(group) {
            return group.value_col === settings.color_by;
        }).label;

        //marks
        var lines = settings.marks.find(function(mark) {
            return mark.type === 'line';
        });
        var hiddenOutliers = settings.marks.find(function(mark) {
            return mark.type === 'circle' && mark.hidden;
        });
        var visibleOutliers = settings.marks.find(function(mark) {
            return mark.type === 'circle' && !mark.hidden;
        });
        lines.per = [settings.color_by];
        hiddenOutliers.radius = visibleOutliers.radius * 4;
        settings.marks
            .filter(function(mark) {
                return mark.type === 'circle';
            })
            .forEach(function(mark) {
                mark.per = [settings.id_col, settings.time_settings.value_col, settings.value_col];
                mark.tooltip =
                    '[' +
                    settings.id_col +
                    '] at [' +
                    settings.x.column +
                    ']: [' +
                    settings.value_col +
                    ']';
            });

        //miscellany
        settings.margin = settings.margin || { bottom: settings.time_settings.vertical_space };

        //Convert unscheduled_visit_pattern from string to regular expression.
        if (
            typeof settings.unscheduled_visit_pattern === 'string' &&
            settings.unscheduled_visit_pattern !== ''
        ) {
            var flags = settings.unscheduled_visit_pattern.replace(/.*?\/([gimy]*)$/, '$1'),
                pattern = settings.unscheduled_visit_pattern.replace(
                    new RegExp('^/(.*?)/' + flags + '$'),
                    '$1'
                );
            settings.unscheduled_visit_regex = new RegExp(pattern, flags);
        }

        return settings;
    }

    function controlInputs() {
        return [
            {
                type: 'subsetter',
                label: 'Measure',
                value_col: 'srot_measure', // set in syncControlInputs()
                start: null // set in ../callbacks/onInit/setInitialMeasure.js
            },
            {
                type: 'dropdown',
                label: 'Group by',
                options: ['marks.0.per.0', 'color_by'],
                start: null, // set in ./syncControlInputs.js
                values: null, // set in ./syncControlInputs.js
                require: true
            },
            {
                type: 'number',
                label: 'Lower',
                grouping: 'y-axis',
                option: 'y.domain[0]',
                require: true
            },
            {
                type: 'number',
                label: 'Upper',
                grouping: 'y-axis',
                option: 'y.domain[1]',
                require: true
            },
            {
                type: 'radio',
                option: 'y.type',
                grouping: 'y-axis',
                values: ['linear', 'log'],
                label: 'Scale'
            },
            {
                type: 'checkbox',
                inline: true,
                option: 'visits_without_data',
                label: 'Visits without data'
            },
            {
                type: 'checkbox',
                inline: true,
                option: 'unscheduled_visits',
                label: 'Unscheduled visits'
            },
            { type: 'checkbox', inline: true, option: 'boxplots', label: 'Box plots' },
            { type: 'checkbox', inline: true, option: 'violins', label: 'Violin plots' },
            { type: 'checkbox', inline: true, option: 'outliers', label: 'Outliers' }
        ];
    }

    function syncControlInputs(controlInputs, settings) {
        //Sync group control.
        var groupControl = controlInputs.find(function(controlInput) {
            return controlInput.label === 'Group by';
        });
        groupControl.start = settings.groups.find(function(group) {
            return group.value_col === settings.color_by;
        }).label;
        groupControl.values = settings.groups.map(function(group) {
            return group.label;
        });

        //Add custom filters to control inputs.
        if (settings.filters) {
            settings.filters.reverse().forEach(function(filter) {
                var thisFilter = {
                    type: 'subsetter',
                    value_col: filter.value_col ? filter.value_col : filter,
                    label: filter.label
                        ? filter.label
                        : filter.value_col ? filter.value_col : filter,
                    description: 'filter'
                };

                //add the filter to the control inputs (as long as it's not already there)
                var current_value_cols = controlInputs
                    .filter(function(f) {
                        return f.type == 'subsetter';
                    })
                    .map(function(m) {
                        return m.value_col;
                    });
                if (current_value_cols.indexOf(thisFilter.value_col) == -1)
                    controlInputs.splice(1, 0, thisFilter);
            });
        }

        //Remove unscheduled visit control if unscheduled visit pattern is unscpecified.
        if (!settings.unscheduled_visit_regex)
            controlInputs.splice(
                controlInputs
                    .map(function(controlInput) {
                        return controlInput.label;
                    })
                    .indexOf('Unscheduled visits'),
                1
            );

        return controlInputs;
    }

    var configuration = {
        rendererSettings: rendererSettings,
        webchartsSettings: webchartsSettings,
        defaultSettings: Object.assign({}, rendererSettings(), webchartsSettings()),
        syncSettings: syncSettings,
        controlInputs: controlInputs,
        syncControlInputs: syncControlInputs
    };

    function countParticipants() {
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

        //Remove missing and non-numeric data.
        var preclean = this.raw_data,
            clean = this.raw_data.filter(function(d) {
                return /^-?[0-9.]+$/.test(d[_this.config.value_col]);
            }),
            nPreclean = preclean.length,
            nClean = clean.length,
            nRemoved = nPreclean - nClean;

        //Warn user of removed records.
        if (nRemoved > 0)
            console.warn(
                nRemoved +
                    ' missing or non-numeric result' +
                    (nRemoved > 1 ? 's have' : ' has') +
                    ' been removed.'
            );
        this.initial_data = clean;
        this.raw_data = clean;
    }

    function addVariables() {
        var _this = this;

        this.raw_data.forEach(function(d) {
            //Convert results to numeric
            d[_this.config.y.column] = parseFloat(d[_this.config.y.column]);

            //Concatenate unit to measure if provided.
            d.srot_measure = d.hasOwnProperty(_this.config.unit_col)
                ? d[_this.config.measure_col] + ' (' + d[_this.config.unit_col] + ')'
                : d[_this.config.measure_col];

            //Add placeholder variable for non-grouped comparisons.
            d.srot_none = 'All Participants';

            //Add placeholder variable for outliers.
            d.srot_outlier = null;
        });
        this.variables = Object.keys(this.raw_data[0]);
    }

    function defineVisitOrder() {
        var _this = this;

        var visits = void 0,
            visitOrder = void 0;

        //Given an ordering variable sort a unique set of visits by the ordering variable.
        if (
            this.config.time_settings.order_col &&
            this.raw_data[0].hasOwnProperty(this.config.time_settings.order_col)
        ) {
            //Define a unique set of visits with visit order concatenated.
            visits = d3
                .set(
                    this.raw_data.map(function(d) {
                        return (
                            d[_this.config.time_settings.order_col] +
                            '|' +
                            d[_this.config.time_settings.value_col]
                        );
                    })
                )
                .values();

            //Sort visits.
            visitOrder = visits
                .sort(function(a, b) {
                    var aOrder = a.split('|')[0],
                        bOrder = b.split('|')[0],
                        diff = +aOrder - +bOrder;
                    return diff ? diff : d3.ascending(a, b);
                })
                .map(function(visit) {
                    return visit.split('|')[1];
                });
        } else {
            //Otherwise sort a unique set of visits alphanumerically.
            //Define a unique set of visits.
            visits = d3
                .set(
                    this.raw_data.map(function(d) {
                        return d[_this.config.time_settings.value_col];
                    })
                )
                .values();

            //Sort visits;
            visitOrder = visits.sort();
        }

        //Set x-axis domain.
        if (this.config.time_settings.order) {
            //If a visit order is specified, use it and concatenate any unspecified visits at the end.
            this.config.x.order = this.config.time_settings.order.concat(
                visitOrder.filter(function(visit) {
                    return _this.config.time_settings.order.indexOf(visit) < 0;
                })
            );
        } else
            //Otherwise use data-driven visit order.
            this.config.x.order = visitOrder;
    }

    function checkFilters() {
        var _this = this;

        this.controls.config.inputs = this.controls.config.inputs.filter(function(input) {
            if (input.type != 'subsetter') {
                return true;
            } else if (!_this.raw_data[0].hasOwnProperty(input.value_col)) {
                console.warn(
                    'The [ ' +
                        input.label +
                        ' ] filter has been removed because the variable does not exist.'
                );
            } else {
                var levels = d3
                    .set(
                        _this.raw_data.map(function(d) {
                            return d[input.value_col];
                        })
                    )
                    .values();

                if (levels.length === 1)
                    console.warn(
                        'The [ ' +
                            input.label +
                            ' ] filter has been removed because the variable has only one level.'
                    );

                return levels.length > 1;
            }
        });
    }

    function checkGroupByVariables() {
        var _this = this;

        var groupByInput = this.controls.config.inputs.find(function(input) {
            return input.label === 'Group by';
        });
        this.config.groups = this.config.groups.filter(function(group) {
            var groupByExists = _this.variables.indexOf(group.value_col) > -1;
            if (!groupByExists)
                console.warn(
                    'The [ ' +
                        group.label +
                        ' ] group-by option has been removed because the variable does not exist.'
                );
            return groupByExists;
        });
        groupByInput.values = this.config.groups.map(function(group) {
            return group.label;
        });
    }

    function defineMeasureSet() {
        var _this = this;

        this.measures = d3
            .set(
                this.initial_data.map(function(d) {
                    return d[_this.config.measure_col];
                })
            )
            .values()
            .sort();
        this.srot_measures = d3
            .set(
                this.initial_data.map(function(d) {
                    return d.srot_measure;
                })
            )
            .values()
            .sort();
    }

    function setInitialMeasure() {
        var measureInput = this.controls.config.inputs.find(function(input) {
            return input.label === 'Measure';
        });
        if (
            this.config.start_value &&
            this.srot_measures.indexOf(this.config.start_value) < 0 &&
            this.measures.indexOf(this.config.start_value) < 0
        ) {
            measureInput.start = this.srot_measures[0];
            console.warn(
                this.config.start_value +
                    ' is an invalid measure. Defaulting to ' +
                    measureInput.start +
                    '.'
            );
        } else if (
            this.config.start_value &&
            this.srot_measures.indexOf(this.config.start_value) < 0
        ) {
            measureInput.start = this.srot_measures[this.measures.indexOf(this.config.start_value)];
            console.warn(
                this.config.start_value +
                    ' is missing the units value. Defaulting to ' +
                    measureInput.start +
                    '.'
            );
        } else measureInput.start = this.config.start_value || this.srot_measures[0];
    }

    function onInit() {
        // 1. Count total participants prior to data cleaning.
        countParticipants.call(this);

        // 2. Drop missing values and remove measures with any non-numeric results.
        cleanData.call(this);

        // 3a Define additional variables.
        addVariables.call(this);

        // 3b Define ordered x-axis domain with visit order variable.
        defineVisitOrder.call(this);

        // 3c Remove filters for nonexistent or single-level variables.
        checkFilters.call(this);

        // 3d Remove group-by options for nonexistent variables.
        checkGroupByVariables.call(this);

        // 4. Define set of measures.
        defineMeasureSet.call(this);

        // 5. Set the start value of the Measure filter.
        setInitialMeasure.call(this);
    }

    function classControlGroups() {
        var checkboxOffset = 0;
        this.controls.wrap
            .style('position', 'relative')
            .selectAll('.control-group')
            .each(function(d, i) {
                var controlGroup = d3.select(this);
                controlGroup.classed(
                    d.type.toLowerCase().replace(' ', '-') +
                        ' ' +
                        d.label.toLowerCase().replace(' ', '-'),
                    true
                );

                //Add y-axis class to group y-axis controls.
                if (d.grouping) controlGroup.classed(d.grouping, true);

                //Float all checkboxes right.
                if (d.type === 'checkbox') {
                    controlGroup.style({
                        position: 'absolute',
                        top: checkboxOffset + 'px',
                        right: 0,
                        margin: '0'
                    });
                    checkboxOffset += controlGroup.node().offsetHeight;
                }
            });
    }

    function customizeGroupByControl() {
        var _this = this;

        var context = this;

        var groupControl = this.controls.wrap.selectAll('.control-group.dropdown.group-by');
        if (groupControl.datum().values.length === 1) groupControl.style('display', 'none');
        else
            groupControl
                .selectAll('select')
                .on('change', function(d) {
                    var label = d3
                        .select(this)
                        .selectAll('option:checked')
                        .text();
                    var value_col = context.config.groups.find(function(group) {
                        return group.label === label;
                    }).value_col;
                    context.config.marks[0].per[0] = value_col;
                    context.config.color_by = value_col;
                    context.config.legend.label = label;
                    context.draw();
                })
                .selectAll('option')
                .property('selected', function(d) {
                    return d === _this.config.legend.label;
                });
    }

    function addYDomainResetButton() {
        var context = this,
            resetContainer = this.controls.wrap
                .insert('div', '.lower')
                .classed('control-group y-axis', true)
                .datum({
                    type: 'button',
                    option: 'y.domain',
                    label: 'Limits'
                }),
            resetLabel = resetContainer
                .append('span')
                .attr('class', 'wc-control-label')
                .text('Limits'),
            resetButton = resetContainer
                .append('button')
                .style('padding', '0px 5px')
                .text('Reset')
                .on('click', function() {
                    var measure_data = context.raw_data.filter(function(d) {
                        return d.srot_measure === context.currentMeasure;
                    });
                    context.config.y.domain = d3.extent(measure_data, function(d) {
                        return +d[context.config.value_col];
                    }); //reset axis to full range

                    context.controls.wrap
                        .selectAll('.control-group')
                        .filter(function(f) {
                            return f.option === 'y.domain[0]';
                        })
                        .select('input')
                        .property('value', context.config.y.domain[0]);

                    context.controls.wrap
                        .selectAll('.control-group')
                        .filter(function(f) {
                            return f.option === 'y.domain[1]';
                        })
                        .select('input')
                        .property('value', context.config.y.domain[1]);

                    context.draw();
                });
    }

    function groupYAxisControls() {
        //Define a container in which to place y-axis controls.
        var grouping = this.controls.wrap
            .insert('div', '.y-axis')
            .style({
                display: 'inline-block',
                'margin-right': '5px'
            })
            .append('fieldset')
            .style('padding', '0px 2px');
        grouping.append('legend').text('Y-axis');

        //Move each y-axis control into container.
        this.controls.wrap.selectAll('.y-axis').each(function(d) {
            this.style.marginTop = '0px';
            this.style.marginRight = '2px';
            this.style.marginBottom = '2px';
            this.style.marginLeft = '2px';
            grouping.node().appendChild(this);

            //Radio buttons sit too low.
            if (d.option === 'y.type')
                d3
                    .select(this)
                    .selectAll('input[type=radio]')
                    .style({
                        top: '-.1em'
                    });
        });
    }

    function addPopulationCountContainer() {
        this.populationCountContainer = this.controls.wrap
            .append('div')
            .classed('population-count', true)
            .style('font-style', 'italic');
    }

    function addBorderAboveChart() {
        this.wrap.style('border-top', '1px solid #ccc');
    }

    function onLayout() {
        classControlGroups.call(this);
        customizeGroupByControl.call(this);
        addYDomainResetButton.call(this);
        groupYAxisControls.call(this);
        addPopulationCountContainer.call(this);
        addBorderAboveChart.call(this);
    }

    function getCurrentMeasure() {
        this.previousMeasure = this.currentMeasure;
        this.currentMeasure = this.controls.wrap
            .selectAll('.control-group')
            .filter(function(d) {
                return d.value_col && d.value_col === 'srot_measure';
            })
            .selectAll('option:checked')
            .text();
        this.config.y.label = this.currentMeasure;
        this.previousYAxis = this.currentYAxis;
        this.currentYAxis = this.config.y.type;
    }

    function defineMeasureData() {
        var _this = this;

        //Filter raw data on selected measure.
        this.measure_data = this.initial_data.filter(function(d) {
            return d.srot_measure === _this.currentMeasure;
        });

        //Remove nonpositive results given log y-axis.
        this.controls.wrap.select('.non-positive-results').remove();
        if (this.config.y.type === 'log') {
            var nResults = this.measure_data.length;
            this.measure_data = this.measure_data.filter(function(d) {
                return +d[_this.config.value_col] > 0;
            });
            var nonPositiveResults = nResults - this.measure_data.length;
            if (nonPositiveResults > 0)
                this.controls.wrap
                    .selectAll('.axis-type .radio')
                    .filter(function() {
                        return (
                            d3
                                .select(this)
                                .select('input')
                                .attr('value') === 'log'
                        );
                    })
                    .append('small')
                    .classed('non-positive-results', true)
                    .text(
                        nonPositiveResults +
                            ' nonpositive result' +
                            (nonPositiveResults > 1 ? 's' : '') +
                            ' removed.'
                    );
        }
        this.raw_data = this.measure_data;

        //Apply filter to measure data.
        this.filtered_measure_data = this.measure_data;
        this.filters.forEach(function(filter) {
            _this.filtered_measure_data = _this.filtered_measure_data.filter(function(d) {
                return Array.isArray(filter.val)
                    ? filter.val.indexOf(d[filter.col]) > -1
                    : filter.val === d[filter.col] || filter.val === 'All';
            });
        });

        //Nest data and calculate summary statistics for each visit-group combination.
        this.nested_measure_data = d3
            .nest()
            .key(function(d) {
                return d[_this.config.x.column];
            })
            .key(function(d) {
                return d[_this.config.color_by];
            })
            .rollup(function(d) {
                var results = {
                    values: d
                        .map(function(m) {
                            return +m[_this.config.y.column];
                        })
                        .sort(d3.ascending),
                    n: d.length
                };

                //Calculate summary statistics.
                [
                    'min',
                    ['quantile', 0.05],
                    ['quantile', 0.25],
                    'median',
                    ['quantile', 0.75],
                    ['quantile', 0.95],
                    'max',
                    'mean',
                    'deviation'
                ].forEach(function(item) {
                    var fx = Array.isArray(item) ? item[0] : item;
                    var stat = Array.isArray(item) ? '' + fx.substring(0, 1) + item[1] * 100 : fx;
                    results[stat] = Array.isArray(item)
                        ? d3[fx](results.values, item[1])
                        : d3[fx](results.values);
                });

                return results;
            })
            .entries(this.filtered_measure_data);
    }

    function flagOutliers() {
        var _this = this;

        this.quantileMap = new Map();
        this.nested_measure_data.forEach(function(visit) {
            visit.values.forEach(function(group) {
                _this.quantileMap.set(
                    visit.key + '|' + group.key, // key
                    [group.values.q5, group.values.q95] // value
                );
            });
        });
        this.filtered_measure_data.forEach(function(d) {
            var quantiles = _this.quantileMap.get(
                d[_this.config.x.column] + '|' + d[_this.config.color_by]
            );
            d.srot_outlier = _this.config.outliers
                ? d[_this.config.y.column] < quantiles[0] || quantiles[1] < d[_this.config.y.column]
                : false;
        });
    }

    function removeVisitsWithoutData() {
        var _this = this;

        if (!this.config.visits_without_data)
            this.config.x.domain = this.config.x.domain.filter(function(visit) {
                return (
                    d3
                        .set(
                            _this.filtered_measure_data.map(function(d) {
                                return d[_this.config.time_settings.value_col];
                            })
                        )
                        .values()
                        .indexOf(visit) > -1
                );
            });
    }

    function removeUnscheduledVisits() {
        var _this = this;

        if (!this.config.unscheduled_visits) {
            if (this.config.unscheduled_visit_values)
                this.config.x.domain = this.config.x.domain.filter(function(visit) {
                    return _this.config.unscheduled_visit_values.indexOf(visit) < 0;
                });
            else if (this.config.unscheduled_visit_regex)
                this.config.x.domain = this.config.x.domain.filter(function(visit) {
                    return !_this.config.unscheduled_visit_regex.test(visit);
                });

            //Remove unscheduled visits from raw data.
            this.raw_data = this.raw_data.filter(function(d) {
                return _this.config.x.domain.indexOf(d[_this.config.time_settings.value_col]) > -1;
            });
        }
    }

    function setXdomain() {
        this.config.x.domain = this.config.x.order;
        removeVisitsWithoutData.call(this);
        removeUnscheduledVisits.call(this);
    }

    function setYdomain() {
        var _this = this;

        //Define y-domain.
        if (
            this.currentMeasure !== this.previousMeasure ||
            this.currentYAxis !== this.previousYAxis
        )
            this.config.y.domain = d3.extent(
                this.measure_data.map(function(d) {
                    return +d[_this.config.y.column];
                })
            );
        else if (this.config.y.domain[0] > this.config.y.domain[1])
            // new measure
            this.config.y.domain.reverse();
        else if (this.config.y.domain[0] === this.config.y.domain[1])
            // invalid domain
            this.config.y.domain = this.config.y.domain.map(function(d, i) {
                return i === 0 ? d - d * 0.01 : d + d * 0.01;
            }); // domain with zero range
    }

    function setYprecision() {
        var _this = this;

        //Calculate range of current measure and the log10 of the range to choose an appropriate precision.
        this.config.y.range = this.config.y.domain[1] - this.config.y.domain[0];
        this.config.y.log10range = Math.log10(this.config.y.range);
        this.config.y.roundedLog10range = Math.round(this.config.y.log10range);
        this.config.y.precision1 = -1 * (this.config.y.roundedLog10range - 1);
        this.config.y.precision2 = -1 * (this.config.y.roundedLog10range - 2);

        //Define the format of the y-axis tick labels and y-domain controls.
        this.config.y.precision = this.config.y.log10range > 0.5 ? 0 : this.config.y.precision1;
        this.config.y.format =
            this.config.y.log10range > 0.5 ? '1f' : '.' + this.config.y.precision1 + 'f';
        this.config.y.d3_format = d3.format(this.config.y.format);
        this.config.y.formatted_domain = this.config.y.domain.map(function(d) {
            return _this.config.y.d3_format(d);
        });

        //Define the bin format: one less than the y-axis format.
        this.config.y.format1 =
            this.config.y.log10range > 5 ? '1f' : '.' + this.config.y.precision2 + 'f';
        this.config.y.d3_format1 = d3.format(this.config.y.format1);
    }

    function updateYaxisResetButton() {
        //Update tooltip of y-axis domain reset button.
        if (this.currentMeasure !== this.previousMeasure)
            this.controls.wrap
                .selectAll('.y-axis')
                .property(
                    'title',
                    'Initial Limits: [' +
                        this.config.y.domain[0] +
                        ' - ' +
                        this.config.y.domain[1] +
                        ']'
                );
    }

    function updateYaxisLimitControls() {
        var _this = this;

        //Update y-axis limit controls.
        var step = Math.pow(10, -this.config.y.precision);
        var yDomain = this.config.y.domain.map(function(limit) {
            return _this.config.y.d3_format(limit);
        });
        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(f) {
                return f.option === 'y.domain[0]';
            })
            .select('input')
            .attr('step', step)
            .property('value', yDomain[0]);
        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(f) {
                return f.option === 'y.domain[1]';
            })
            .select('input')
            .attr('step', step)
            .property('value', yDomain[1]);
    }

    function onPreprocess() {
        // 1. Capture currently selected measure.
        getCurrentMeasure.call(this);

        // 2. Filter data on currently selected measure.
        defineMeasureData.call(this);

        // 3a Flag outliers with quantiles calculated in defineMeasureData().
        flagOutliers.call(this);

        // 3a Set x-domain given current visit settings.
        setXdomain.call(this);

        // 3b Set y-domain given currently selected measure.
        setYdomain.call(this);

        // 4a Define precision of measure.
        setYprecision.call(this);

        // 4b Update y-axis reset button when measure changes.
        updateYaxisResetButton.call(this);

        // 4c Update y-axis limit controls to match y-axis domain.
        updateYaxisLimitControls.call(this);
    }

    function onDatatransform() {}

    function updateParticipantCount() {
        var _this = this;

        this.populationCountContainer.selectAll('*').remove();
        var subpopulationCount = d3
            .set(
                this.filtered_data.map(function(d) {
                    return d[_this.config.id_col];
                })
            )
            .values().length;
        var percentage = d3.format('0.1%')(subpopulationCount / this.populationCount);
        this.populationCountContainer.html(
            '\n' +
                subpopulationCount +
                ' of ' +
                this.populationCount +
                ' participants  shown (' +
                percentage +
                ')'
        );
    }

    function removeUnscheduledVisits$1() {
        var _this = this;

        if (!this.config.unscheduled_visits)
            this.marks.forEach(function(mark) {
                if (mark.type === 'line')
                    mark.data.forEach(function(d) {
                        d.values = d.values.filter(function(di) {
                            return _this.config.x.domain.indexOf(di.key) > -1;
                        });
                    });
                else if (mark.type === 'circle')
                    mark.data = mark.data.filter(function(d) {
                        return _this.config.x.domain.indexOf(d.values.x) > -1;
                    });
            });
    }

    function clearCanvas() {
        this.svg.selectAll('.y.axis .tick').remove();
        this.svg.selectAll('.point').remove(); // mark data doesn't necessarily get updated (?)
        this.svg.selectAll('.boxplot-wrap').remove();
    }

    function updateMarkData() {
        var _this = this;

        this.marks.forEach(function(mark, i) {
            mark.hidden = _this.config.marks[i].hidden;
        });
        this.marks
            .filter(function(mark) {
                return mark.type === 'circle';
            })
            .forEach(function(mark) {
                mark.data.forEach(function(d, i) {
                    d.id = 'outlier-' + i;
                    d.hidden = mark.hidden;
                    d.visit = d.values.x;
                    d.group = d.values.raw[0][_this.config.color_by];
                });
            });
    }

    function onDraw() {
        updateParticipantCount.call(this);
        clearCanvas.call(this);
        removeUnscheduledVisits$1.call(this);
        updateMarkData.call(this);
    }

    function editXAxisTicks() {
        //Rotate x-axis tick labels.
        if (this.config.time_settings.rotate_tick_labels)
            this.svg
                .selectAll('.x.axis .tick text')
                .attr({
                    transform: 'rotate(-45)',
                    dx: -10,
                    dy: 10
                })
                .style('text-anchor', 'end');
    }

    function drawLogAxis() {
        //Draw custom y-axis given a log scale.
        if (this.config.y.type === 'log') {
            var logYAxis = d3.svg
                .axis()
                .scale(this.y)
                .orient('left')
                .ticks(8, ',' + this.config.y.format)
                .tickSize(6, 0);
            this.svg.select('g.y.axis').call(logYAxis);
        }
    }

    function handleEmptyAxis() {
        var _this = this;

        //Manually draw y-axis ticks when none exist.
        if (this.svg.selectAll('.y .tick').size() < 2) {
            //Define quantiles of current measure results.
            var probs = [
                { probability: 0.1 },
                { probability: 0.3 },
                { probability: 0.5 },
                { probability: 0.7 },
                { probability: 0.9 }
            ];

            for (var i = 0; i < probs.length; i++) {
                probs[i].quantile = d3.quantile(
                    this.measure_data
                        .map(function(d) {
                            return +d[_this.config.y.column];
                        })
                        .sort(function(a, b) {
                            return a - b;
                        }),
                    probs[i].probability
                );
            }

            var ticks = probs.map(function(prob) {
                return prob.quantile;
            });

            //Manually define y-axis tick values.
            this.yAxis.tickValues(ticks);

            //Transition the y-axis to draw the ticks.
            this.svg
                .select('g.y.axis')
                .transition()
                .call(this.yAxis);

            //Draw the gridlines.
            this.drawGridlines();
        }
    }

    function removeDuplicateTickLabels() {
        //Manually remove excess y-axis ticks.
        var tickLabels = [];
        this.svg.selectAll('.y.axis .tick').each(function(d) {
            var tick = d3.select(this);
            var label = tick.select('text');

            if (label.size()) {
                var tickLabel = label.text();

                //Check if tick value already exists on axis and if so, remove.
                if (tickLabels.indexOf(tickLabel) < 0) tickLabels.push(tickLabel);
                else label.remove();
            }
        });
    }

    function fixFloatingPointIssues() {
        this.svg
            .selectAll('.y.axis .tick text')
            .filter(function(d) {
                return /^\d*\.0*[1-9]0{5,}[1-9]$/.test(d);
            }) // floating point issues, e.g. .2 + .1 !== .3
            .remove();
    }

    function editYAxisTicks() {
        drawLogAxis.call(this);
        handleEmptyAxis.call(this);
        removeDuplicateTickLabels.call(this);
        fixFloatingPointIssues.call(this);
    }

    function clearCanvas$1() {
        this.svg.selectAll('.boxplot-wrap').remove();
    }

    function defineScales(subgroup) {
        subgroup.boxplot.x = d3.scale.linear().range([0, this.x.rangeBand()]);
        subgroup.boxplot.left = subgroup.boxplot.x(0.5 - subgroup.boxplot.boxPlotWidth / 2);
        subgroup.boxplot.right = subgroup.boxplot.x(0.5 + subgroup.boxplot.boxPlotWidth / 2);
        subgroup.boxplot.y =
            this.config.y.type === 'linear'
                ? d3.scale
                      .linear()
                      .range([this.plot_height, 0])
                      .domain(this.y.domain())
                : d3.scale
                      .log()
                      .range([this.plot_height, 0])
                      .domain(this.y.domain());
    }

    function addContainer(subgroup) {
        subgroup.boxplot.container = subgroup.svg
            .append('g')
            .attr('class', 'boxplot')
            .datum({
                values: subgroup.results.values,
                probs: subgroup.boxplot.probs
            })
            .attr('clip-path', 'url(#' + this.id + ')');
    }

    function drawBox(subgroup) {
        subgroup.boxplot.container
            .append('rect')
            .attr({
                class: 'boxplot fill',
                x: subgroup.boxplot.left,
                width: subgroup.boxplot.right - subgroup.boxplot.left,
                y: subgroup.boxplot.y(subgroup.boxplot.probs[3]),
                height:
                    subgroup.boxplot.y(subgroup.boxplot.probs[1]) -
                    subgroup.boxplot.y(subgroup.boxplot.probs[3])
            })
            .style('fill', subgroup.boxplot.boxColor);
    }

    function drawHorizontalLines(subgroup) {
        var iS = [0, 2, 4];
        var iSclass = ['', 'median', ''];
        var iSColor = [
            subgroup.boxplot.boxColor,
            subgroup.boxplot.boxInsideColor,
            subgroup.boxplot.boxColor
        ];
        for (var i = 0; i < iS.length; i++) {
            subgroup.boxplot.container
                .append('line')
                .attr({
                    class: 'boxplot ' + iSclass[i],
                    x1: subgroup.boxplot.left,
                    x2: subgroup.boxplot.right,
                    y1: subgroup.boxplot.y(subgroup.boxplot.probs[iS[i]]),
                    y2: subgroup.boxplot.y(subgroup.boxplot.probs[iS[i]])
                })
                .style({
                    fill: iSColor[i],
                    stroke: iSColor[i]
                });
        }
    }

    function drawVerticalLines(subgroup) {
        var iS = [[0, 1], [3, 4]];
        for (var i = 0; i < iS.length; i++) {
            subgroup.boxplot.container
                .append('line')
                .attr({
                    class: 'boxplot',
                    x1: subgroup.boxplot.x(0.5),
                    x2: subgroup.boxplot.x(0.5),
                    y1: subgroup.boxplot.y(subgroup.boxplot.probs[iS[i][0]]),
                    y2: subgroup.boxplot.y(subgroup.boxplot.probs[iS[i][1]])
                })
                .style('stroke', subgroup.boxplot.boxColor);
        }
    }

    function drawOuterCircle(subgroup) {
        subgroup.boxplot.container
            .append('circle')
            .attr({
                class: 'boxplot mean',
                cx: subgroup.boxplot.x(0.5),
                cy: subgroup.boxplot.y(subgroup.results.mean),
                r: Math.min(subgroup.boxplot.x(subgroup.boxplot.boxPlotWidth / 3), 10)
            })
            .style({
                fill: subgroup.boxplot.boxInsideColor,
                stroke: subgroup.boxplot.boxColor
            });
    }

    function drawInnerCircle(subgroup) {
        subgroup.boxplot.container
            .append('circle')
            .attr({
                class: 'boxplot mean',
                cx: subgroup.boxplot.x(0.5),
                cy: subgroup.boxplot.y(subgroup.results.mean),
                r: Math.min(subgroup.boxplot.x(subgroup.boxplot.boxPlotWidth / 6), 5)
            })
            .style({
                fill: subgroup.boxplot.boxColor,
                stroke: 'none'
            });
    }

    function addBoxPlot(subgroup) {
        //Attach needed stuff to subgroup object.
        subgroup.boxplot = {
            boxPlotWidth: 0.75 / this.colorScale.domain().length,
            boxColor: this.colorScale(subgroup.key),
            boxInsideColor: '#eee',
            probs: ['q5', 'q25', 'median', 'q75', 'q95'].map(function(prob) {
                return subgroup.results[prob];
            })
        };

        //Draw box plot.
        defineScales.call(this, subgroup);
        addContainer.call(this, subgroup);
        drawBox.call(this, subgroup);
        drawHorizontalLines.call(this, subgroup);
        drawVerticalLines.call(this, subgroup);
        drawOuterCircle.call(this, subgroup);
        drawInnerCircle.call(this, subgroup);
    }

    function defineData(subgroup) {
        //Define histogram data.
        subgroup.violinPlot = {
            histogram: d3.layout
                .histogram()
                .bins(10)
                .frequency(0)
        };
        (subgroup.violinPlot.data = subgroup.violinPlot.histogram(subgroup.results.values)),
            subgroup.violinPlot.data.unshift({
                x: subgroup.results.min,
                dx: 0,
                y: subgroup.violinPlot.data[0].y
            });
        subgroup.violinPlot.data.push({
            x: subgroup.results.max,
            dx: 0,
            y: subgroup.violinPlot.data[subgroup.violinPlot.data.length - 1].y
        });
    }

    function defineScales$1(subgroup) {
        subgroup.violinPlot.width = this.x.rangeBand();
        subgroup.violinPlot.x =
            this.config.y.type === 'linear'
                ? d3.scale
                      .linear()
                      .domain(this.y.domain())
                      .range([this.plot_height, 0])
                : d3.scale
                      .log()
                      .domain(this.y.domain())
                      .range([this.plot_height, 0]);
        subgroup.violinPlot.y = d3.scale
            .linear()
            .domain([
                0,
                Math.max(
                    1 - 1 / subgroup.group.x.nGroups,
                    d3.max(subgroup.violinPlot.data, function(d) {
                        return d.y;
                    })
                )
            ])
            .range([subgroup.violinPlot.width / 2, 0]);
    }

    function addContainer$1(subgroup) {
        //Define violin shapes.
        subgroup.violinPlot.area = d3.svg
            .area()
            .interpolate('basis')
            .x(function(d) {
                return subgroup.violinPlot.x(d.x + d.dx / 2);
            })
            .y0(subgroup.violinPlot.width / 2)
            .y1(function(d) {
                return subgroup.violinPlot.y(d.y);
            });
        subgroup.violinPlot.line = d3.svg
            .line()
            .interpolate('basis')
            .x(function(d) {
                return subgroup.violinPlot.x(d.x + d.dx / 2);
            })
            .y(function(d) {
                return subgroup.violinPlot.y(d.y);
            });
        subgroup.violinPlot.container = subgroup.svg
            .append('g')
            .attr('class', 'violinplot')
            .attr('clip-path', 'url(#' + this.id + ')');
    }

    function drawLeftSide(subgroup) {
        subgroup.violinPlot.gMinus = subgroup.violinPlot.container
            .append('g')
            .attr('transform', 'rotate(90,0,0) scale(1,-1)');
        subgroup.violinPlot.gMinus
            .append('path')
            .datum(subgroup.violinPlot.data)
            .attr({
                class: 'area',
                d: subgroup.violinPlot.area,
                fill: this.colorScale(subgroup.key),
                'fill-opacity': 0.75
            });
        subgroup.violinPlot.gMinus
            .append('path')
            .datum(subgroup.violinPlot.data)
            .attr({
                class: 'violin',
                d: subgroup.violinPlot.line,
                stroke: this.colorScale(subgroup.key),
                fill: 'none'
            });
    }

    function drawRightSide(subgroup) {
        subgroup.violinPlot.gPlus = subgroup.violinPlot.container
            .append('g')
            .attr('transform', 'rotate(90,0,0) translate(0,-' + subgroup.violinPlot.width + ')');
        subgroup.violinPlot.gPlus
            .append('path')
            .datum(subgroup.violinPlot.data)
            .attr({
                class: 'area',
                d: subgroup.violinPlot.area,
                fill: this.colorScale(subgroup.key),
                'fill-opacity': 0.75
            });
        subgroup.violinPlot.gPlus
            .append('path')
            .datum(subgroup.violinPlot.data)
            .attr({
                class: 'violin',
                d: subgroup.violinPlot.line,
                stroke: this.colorScale(subgroup.key),
                fill: 'none'
            });
    }

    function addViolinPlot(subgroup) {
        defineData.call(this, subgroup);
        defineScales$1.call(this, subgroup);
        addContainer$1.call(this, subgroup);
        drawLeftSide.call(this, subgroup);
        drawRightSide.call(this, subgroup);
    }

    function addSummaryStatistics(subgroup) {
        var format0 = d3.format('.' + (this.config.y.precision + 0) + 'f');
        var format1 = d3.format('.' + (this.config.y.precision + 1) + 'f');
        var format2 = d3.format('.' + (this.config.y.precision + 2) + 'f');
        subgroup.svg
            .selectAll('g')
            .append('title')
            .html(function(d) {
                return (
                    subgroup.key +
                    ' at ' +
                    subgroup.group.x.key +
                    ':\n&nbsp;&nbsp;&nbsp;&nbsp;N = ' +
                    subgroup.results.n +
                    '\n&nbsp;&nbsp;&nbsp;&nbsp;Min = ' +
                    format0(subgroup.results.min) +
                    '\n&nbsp;&nbsp;&nbsp;&nbsp;5th % = ' +
                    format1(subgroup.results.q5) +
                    '\n&nbsp;&nbsp;&nbsp;&nbsp;Q1 = ' +
                    format1(subgroup.results.q25) +
                    '\n&nbsp;&nbsp;&nbsp;&nbsp;Median = ' +
                    format1(subgroup.results.median) +
                    '\n&nbsp;&nbsp;&nbsp;&nbsp;Q3 = ' +
                    format1(subgroup.results.q75) +
                    '\n&nbsp;&nbsp;&nbsp;&nbsp;95th % = ' +
                    format1(subgroup.results.q95) +
                    '\n&nbsp;&nbsp;&nbsp;&nbsp;Max = ' +
                    format0(subgroup.results.max) +
                    '\n&nbsp;&nbsp;&nbsp;&nbsp;Mean = ' +
                    format1(subgroup.results.mean) +
                    '\n&nbsp;&nbsp;&nbsp;&nbsp;StDev = ' +
                    format2(subgroup.results.deviation)
                );
            });
    }

    function drawPlots() {
        var _this = this;

        this.nested_measure_data
            .filter(function(visit) {
                return _this.x_dom.indexOf(visit.key) > -1;
            })
            .forEach(function(visit) {
                // iterate over groups
                //Sort [ config.color_by ] groups.
                visit.values = visit.values.sort(function(a, b) {
                    return _this.colorScale.domain().indexOf(a.key) <
                        _this.colorScale.domain().indexOf(b.key)
                        ? -1
                        : 1;
                });

                //Define group object.
                var groupObject = {
                    x: {
                        key: visit.key, // x-axis value
                        nGroups: _this.colorScale.domain().length, // number of groups at x-axis value
                        width: _this.x.rangeBand() // width of x-axis value
                    },
                    subgroups: []
                };
                groupObject.x.start = -(groupObject.x.nGroups / 2) + 0.5;
                groupObject.distance = groupObject.x.width / groupObject.x.nGroups;

                visit.values.forEach(function(group, i) {
                    //Iterate over visits.
                    var subgroup = {
                        group: groupObject,
                        key: group.key,
                        offset: (groupObject.x.start + i) * groupObject.distance,
                        results: group.values
                    };
                    subgroup.svg = _this.svg
                        .insert('g', '.point-supergroup')
                        .attr({
                            class: 'boxplot-wrap overlay-item',
                            transform:
                                'translate(' +
                                (_this.x(groupObject.x.key) + subgroup.offset) +
                                ',0)'
                        })
                        .datum({ values: subgroup.results });
                    groupObject.subgroups.push(subgroup);

                    if (_this.config.boxplots) addBoxPlot.call(_this, subgroup);
                    if (_this.config.violins) addViolinPlot.call(_this, subgroup);
                    addSummaryStatistics.call(_this, subgroup);

                    //Offset outliers.
                    _this.marks
                        .filter(function(mark) {
                            return mark.type === 'circle';
                        })
                        .forEach(function(mark) {
                            mark.groups
                                .filter(function(d) {
                                    return d.visit === visit.key && d.group === group.key;
                                })
                                .attr('transform', 'translate(' + subgroup.offset + ',0)');
                        });
                });
            });
    }

    function addMouseoverToOutliers() {
        var _this = this;

        this.marks
            .filter(function(mark) {
                return mark.type === 'circle';
            })
            .forEach(function(mark) {
                mark.groups
                    .each(function(d, i) {
                        d3.select(this).classed('hidden-' + d.hidden + ' ' + d.id, true);
                    })
                    .on('mouseover', function(d) {
                        _this.svg.select('.hidden-true.' + d.id + ' circle').attr({
                            'fill-opacity': 1,
                            'stroke-opacity': 1
                        });
                    })
                    .on('mouseout', function(d) {
                        _this.svg.select('.hidden-true.' + d.id + ' circle').attr({
                            'fill-opacity': 0,
                            'stroke-opacity': 0
                        });
                    });
            });
    }

    function removeLegend() {
        if (this.config.color_by === 'srot_none') this.wrap.select('.legend').remove();
    }

    function onResize() {
        editXAxisTicks.call(this);
        editYAxisTicks.call(this);
        clearCanvas$1.call(this);
        drawPlots.call(this);
        addMouseoverToOutliers.call(this);
        removeLegend.call(this);
    }

    function onDestroy() {}

    var callbacks = {
        onInit: onInit,
        onLayout: onLayout,
        onPreprocess: onPreprocess,
        onDatatransform: onDatatransform,
        onDraw: onDraw,
        onResize: onResize,
        onDestroy: onDestroy
    };

    function safetyResultsOverTime(element, settings) {
        var mergedSettings = merge(configuration.defaultSettings, settings); //Merge user settings onto default settings.
        var syncedSettings = configuration.syncSettings(mergedSettings); //Sync properties within merged settings, e.g. data mappings.
        var syncedControlInputs = configuration.syncControlInputs(
            configuration.controlInputs(),
            syncedSettings
        ); //Sync merged settings with controls.

        //Define controls.
        var controls = webcharts.createControls(element, {
            location: 'top',
            inputs: syncedControlInputs
        });

        //Define chart.
        var chart = webcharts.createChart(element, syncedSettings, controls);

        //Attach callbacks to chart.
        for (var callback in callbacks) {
            chart.on(callback.substring(2).toLowerCase(), callbacks[callback]);
        }
        return chart;
    }

    return safetyResultsOverTime;
});
