(function(global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined'
        ? (module.exports = factory(require('d3'), require('webcharts')))
        : typeof define === 'function' && define.amd
          ? define(['d3', 'webcharts'], factory)
          : ((global = global || self),
            (global.safetyOutlierExplorer = factory(global.d3, global.webCharts)));
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

    // https://github.com/wbkd/d3-extended
    d3.selection.prototype.moveToFront = function() {
        return this.each(function() {
            this.parentNode.appendChild(this);
        });
    };

    d3.selection.prototype.moveToBack = function() {
        return this.each(function() {
            var firstChild = this.parentNode.firstChild;
            if (firstChild) {
                this.parentNode.insertBefore(this, firstChild);
            }
        });
    };

    function rendererSettings() {
        return {
            //participant
            id_col: 'USUBJID',
            details: [
                { value_col: 'AGE', label: 'Age' },
                { value_col: 'SEX', label: 'Sex' },
                { value_col: 'RACE', label: 'Race' }
            ],

            //timing
            time_cols: [
                {
                    type: 'ordinal',
                    value_col: 'VISIT',
                    label: 'Visit',
                    order_col: 'VISITNUM',
                    order: null,
                    rotate_tick_labels: true,
                    vertical_space: 100
                },
                {
                    type: 'linear',
                    value_col: 'DY',
                    label: 'Study Day',
                    order_col: 'DY',
                    order: null,
                    rotate_tick_labels: false,
                    vertical_space: 0
                }
            ],
            visits_without_data: false,
            unscheduled_visits: false,
            unscheduled_visit_pattern: '/unscheduled|early termination/i',
            unscheduled_visit_values: null, // takes precedence over unscheduled_visit_pattern

            //measure
            measure_col: 'TEST',
            start_value: null,
            unit_col: 'STRESU',

            //result
            value_col: 'STRESN',

            //normal range
            normal_col_low: 'STNRLO',
            normal_col_high: 'STNRHI',
            normal_range_method: 'LLN-ULN',
            normal_range_sd: 1.96,
            normal_range_quantile_low: 0.05,
            normal_range_quantile_high: 0.95,

            //filters
            filters: null,

            //marks
            line_attributes: {
                stroke: 'black',
                'stroke-width': 0.5,
                'stroke-opacity': 0.75
            },
            point_attributes: {
                stroke: '#1f78b4',
                'stroke-width': 0.5,
                'stroke-opacity': 1,
                radius: 3,
                fill: '#1f78b4',
                'fill-opacity': 0.2
            },
            tooltip_cols: null,
            custom_marks: null,

            //multiples
            multiples_sizing: {
                width: 300,
                height: 100
            }
        };
    }

    function webchartsSettings() {
        return {
            x: {
                column: null, // set in ./syncSettings
                type: null, // set in ./syncSettings
                behavior: 'raw'
            },
            y: {
                column: null, // set in ./syncSettings
                stat: 'mean',
                type: 'linear',
                label: 'Value',
                behavior: 'raw'
            },
            marks: [
                {
                    per: null, // set in ./syncSettings
                    type: 'line',
                    attributes: {
                        'clip-path': null // set in ./syncSettings
                    },
                    tooltip: null, // set in ./syncSettings
                    default: true
                },
                {
                    per: null, // set in ./syncSettings
                    type: 'circle',
                    attributes: {
                        'clip-path': null // set in ./syncSettings
                    },
                    tooltip: null, // set in ./syncSettings
                    default: true
                }
            ],
            resizable: true,
            margin: {
                right: 30, // create space for box plot
                left: 60
            },
            gridlines: 'y',
            aspect: 3
        };
    }

    function syncSettings(settings) {
        var time_col = settings.time_cols[0];

        //x-axis
        settings.x.column = time_col.value_col;
        settings.x.type = time_col.type;
        settings.x.label = time_col.label;
        settings.x.order = time_col.order;

        //y-axis
        settings.y.column = settings.value_col;

        //lines
        var lines = settings.marks.find(function(mark) {
            return mark.type === 'line';
        });
        lines.per = [settings.id_col, settings.measure_col];
        lines.tooltip = '[' + settings.id_col + ']';
        Object.assign(lines.attributes, settings.line_attributes);
        lines.attributes['stroke-width'] = settings.line_attributes['stroke-width'] || 0.5;

        //points
        var points = settings.marks.find(function(mark) {
            return mark.type === 'circle';
        });
        points.per = [
            settings.id_col,
            settings.measure_col,
            time_col.value_col,
            settings.value_col
        ];
        points.tooltip =
            'Participant = [' +
            settings.id_col +
            ']\n[' +
            settings.measure_col +
            '] = [' +
            settings.value_col +
            '] [' +
            settings.unit_col +
            ']\n' +
            settings.x.label +
            ' = [' +
            settings.x.column +
            ']';

        //Conadd custom tooltip values
        if (settings.tooltip_cols) {
            settings.tooltip_cols.forEach(function(tooltip) {
                var obj =
                    typeof tooltip == 'string' ? { label: tooltip, value_col: tooltip } : tooltip;
                points.tooltip = points.tooltip + ('\n' + obj.label + ' = [' + obj.value_col + ']');
            });
        }

        Object.assign(points.attributes, settings.point_attributes);
        points.radius = settings.point_attributes.radius || 3;

        //Add custom marks to settings.marks.
        if (Array.isArray(settings.custom_marks) && settings.custom_marks.length)
            settings.custom_marks.forEach(function(mark) {
                if (mark instanceof Object) {
                    mark.default = false; // distinguish custom marks from default marks
                    if (mark.type === 'line')
                        mark.attributes = Object.assign({}, lines.attributes, mark.attributes);
                    else if (mark.type === 'circle') {
                        mark.attributes = Object.assign({}, points.attributes, mark.attributes);
                        mark.radius = mark.radius || points.radius;
                    }
                    settings.marks.push(mark);
                }
            });

        //Define margins for box plot and rotated x-axis tick labels.
        if (settings.margin) settings.margin.bottom = time_col.vertical_space;
        else
            settings.margin = {
                right: 20,
                bottom: time_col.vertical_space
            };

        settings.rotate_x_tick_labels = time_col.rotate_tick_labels;

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
                value_col: 'soe_measure', // set in syncControlInputs()
                label: 'Measure',
                start: null
            },
            {
                type: 'dropdown',
                option: 'x.column',
                label: 'X-axis',
                require: true
            },
            {
                type: 'number',
                option: 'y.domain[0]',
                label: 'Lower',
                require: true
            },
            {
                type: 'number',
                option: 'y.domain[1]',
                label: 'Upper',
                require: true
            },
            {
                type: 'dropdown',
                option: 'normal_range_method',
                label: 'Method',
                values: ['None', 'LLN-ULN', 'Standard Deviation', 'Quantiles'],
                require: true
            },
            {
                type: 'number',
                option: 'normal_range_sd',
                label: '# Std. Dev.'
            },
            {
                type: 'number',
                label: 'Lower',
                option: 'normal_range_quantile_low'
            },
            {
                type: 'number',
                label: 'Upper',
                option: 'normal_range_quantile_high'
            },
            {
                type: 'checkbox',
                inline: true,
                option: 'visits_without_data',
                label: 'Without Data'
            },
            {
                type: 'checkbox',
                inline: true,
                option: 'unscheduled_visits',
                label: 'Unscheduled'
            }
        ];
    }

    function syncControlInputs(controlInputs, settings) {
        var xAxisControl = controlInputs.find(function(d) {
            return d.label === 'X-axis';
        });
        xAxisControl.values = settings.time_cols.map(function(d) {
            return d.value_col;
        });

        if (settings.filters) {
            settings.filters.forEach(function(d, i) {
                var thisFilter = {
                    type: 'subsetter',
                    value_col: d.value_col ? d.value_col : d,
                    label: d.label ? d.label : d.value_col ? d.value_col : d
                };
                //add the filter to the control inputs (as long as it isn't already there)
                var current_value_cols = controlInputs
                    .filter(function(f) {
                        return f.type == 'subsetter';
                    })
                    .map(function(m) {
                        return m.value_col;
                    });
                if (current_value_cols.indexOf(thisFilter.value_col) == -1)
                    controlInputs.splice(4 + i, 0, thisFilter);
            });
        }

        //Remove unscheduled visit control if unscheduled visit pattern is unscpecified.
        if (
            !settings.unscheduled_visit_regex &&
            !(
                Array.isArray(settings.unscheduled_visit_values) &&
                settings.unscheduled_visit_values.length
            )
        )
            controlInputs.splice(
                controlInputs
                    .map(function(controlInput) {
                        return controlInput.label;
                    })
                    .indexOf('Unscheduled Visits'),
                1
            );

        return controlInputs;
    }

    var configuration = {
        rendererSettings: rendererSettings,
        webchartsSettings: webchartsSettings,
        settings: Object.assign({}, rendererSettings(), webchartsSettings()),
        syncSettings: syncSettings,
        controlInputs: controlInputs,
        syncControlInputs: syncControlInputs
    };

    function countParticipants() {
        var _this = this;

        this.participantCount = {
            N: d3
                .set(
                    this.raw_data.map(function(d) {
                        return d[_this.config.id_col];
                    })
                )
                .values()
                .filter(function(value) {
                    return !/^\s*$/.test(value);
                }).length,
            container: null, // set in ../onLayout/addParticipantCountContainer
            n: null, // set in ../onDraw/updateParticipantCount
            percentage: null // set in ../onDraw/updateParticipantCount
        };
    }

    function removeMissingResults() {
        var _this = this;

        //Split data into records with missing and nonmissing results.
        var missingResults = [];
        var nonMissingResults = [];
        this.raw_data.forEach(function(d) {
            if (/^\s*$/.test(d[_this.config.value_col])) missingResults.push(d);
            else nonMissingResults.push(d);
        });

        //Nest missing and nonmissing results by participant.
        var participantsWithMissingResults = d3
            .nest()
            .key(function(d) {
                return d[_this.config.id_col];
            })
            .rollup(function(d) {
                return d.length;
            })
            .entries(missingResults);
        var participantsWithNonMissingResults = d3
            .nest()
            .key(function(d) {
                return d[_this.config.id_col];
            })
            .rollup(function(d) {
                return d.length;
            })
            .entries(nonMissingResults);

        //Identify placeholder records, i.e. participants with a single missing result.
        this.removedRecords.placeholderRecords = participantsWithMissingResults
            .filter(function(d) {
                return (
                    participantsWithNonMissingResults
                        .map(function(d) {
                            return d.key;
                        })
                        .indexOf(d.key) < 0 && d.values === 1
                );
            })
            .map(function(d) {
                return d.key;
            });
        if (this.removedRecords.placeholderRecords.length)
            console.log(
                this.removedRecords.placeholderRecords.length +
                    ' participants without results have been detected.'
            );

        //Count the number of records with missing results.
        this.removedRecords.missing = d3.sum(
            participantsWithMissingResults.filter(function(d) {
                return _this.removedRecords.placeholderRecords.indexOf(d.key) < 0;
            }),
            function(d) {
                return d.values;
            }
        );
        if (this.removedRecords.missing > 0)
            console.warn(
                this.removedRecords.missing +
                    ' record' +
                    (this.removedRecords.missing > 1
                        ? 's with a missing result have'
                        : ' with a missing result has') +
                    ' been removed.'
            );

        //Update data.
        this.raw_data = nonMissingResults;
    }

    function removeNonNumericResults() {
        var _this = this;

        //Filter out non-numeric results.
        var numericResults = this.raw_data.filter(function(d) {
            return /^-?[0-9.]+$/.test(d[_this.config.value_col]);
        });
        this.removedRecords.nonNumeric = this.raw_data.length - numericResults.length;
        if (this.removedRecords.nonNumeric > 0)
            console.warn(
                this.removedRecords.nonNumeric +
                    ' record' +
                    (this.removedRecords.nonNumeric > 1
                        ? 's with a non-numeric result have'
                        : ' with a non-numeric result has') +
                    ' been removed.'
            );

        //Update data.
        this.raw_data = numericResults;
    }

    function cleanData() {
        this.removedRecords = {
            placeholderParticipants: null, // defined in './cleanData/removeMissingResults
            missing: null, // defined in './cleanData/removeMissingResults
            nonNumeric: null, // defined in './cleanData/removeNonNumericResults
            container: null // defined in ../onLayout/addRemovedRecordsContainer
        };
        removeMissingResults.call(this);
        removeNonNumericResults.call(this);
        this.initial_data = this.raw_data;
    }

    function addVariables() {
        var _this = this;

        var ordinalTimeSettings = this.config.time_cols.find(function(time_col) {
            return time_col.type === 'ordinal';
        });

        this.raw_data.forEach(function(d) {
            //Concatenate unit to measure if provided.
            d.soe_measure = d.hasOwnProperty(_this.config.unit_col)
                ? d[_this.config.measure_col] + ' (' + d[_this.config.unit_col] + ')'
                : d[_this.config.measure_col];

            //Identify unscheduled visits.
            d.unscheduled = false;
            if (ordinalTimeSettings) {
                if (_this.config.unscheduled_visit_values)
                    d.unscheduled =
                        _this.config.unscheduled_visit_values.indexOf(
                            d[ordinalTimeSettings.value_col]
                        ) > -1;
                else if (_this.config.unscheduled_visit_regex)
                    d.unscheduled = _this.config.unscheduled_visit_regex.test(
                        d[ordinalTimeSettings.value_col]
                    );
            }
        });
    }

    function participant() {
        var _this = this;

        this.IDOrder = d3
            .set(
                this.raw_data.map(function(d) {
                    return d[_this.config.id_col];
                })
            )
            .values()
            .sort()
            .map(function(ID, i) {
                return {
                    ID: ID,
                    order: i
                };
            });
    }

    function visit() {
        var _this = this;

        //ordinal
        this.config.time_cols
            .filter(function(time_col) {
                return time_col.type === 'ordinal';
            })
            .forEach(function(time_settings) {
                var visits = void 0,
                    visitOrder = void 0;

                //Given an ordering variable sort a unique set of visits by the ordering variable.
                if (
                    time_settings.order_col &&
                    _this.raw_data[0].hasOwnProperty(time_settings.order_col)
                ) {
                    //Define a unique set of visits with visit order concatenated.
                    visits = d3
                        .set(
                            _this.raw_data.map(function(d) {
                                return (
                                    d[time_settings.order_col] + '|' + d[time_settings.value_col]
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
                            _this.raw_data.map(function(d) {
                                return d[time_settings.value_col];
                            })
                        )
                        .values();

                    //Sort visits;
                    visitOrder = visits.sort();
                }

                //Set x-axis domain.
                if (time_settings.order) {
                    //If a visit order is specified, use it and concatenate any unspecified visits at the end.
                    time_settings.order = time_settings.order.concat(
                        visitOrder.filter(function(visit) {
                            return time_settings.order.indexOf(visit) < 0;
                        })
                    );
                } else
                    //Otherwise use data-driven visit order.
                    time_settings.order = visitOrder;

                //Define domain.
                time_settings.domain = time_settings.order;
            });
    }

    function measure() {
        var _this = this;

        this.measures = d3
            .set(
                this.initial_data.map(function(d) {
                    return d[_this.config.measure_col];
                })
            )
            .values()
            .sort();
        this.soe_measures = d3
            .set(
                this.initial_data.map(function(d) {
                    return d.soe_measure;
                })
            )
            .values()
            .sort();
    }

    function defineSets() {
        participant.call(this);
        visit.call(this);
        measure.call(this);
    }

    function updateMeasureFilter() {
        this.measure = {};
        var measureInput = this.controls.config.inputs.find(function(input) {
            return input.label === 'Measure';
        });
        if (
            this.config.start_value &&
            this.soe_measures.indexOf(this.config.start_value) < 0 &&
            this.measures.indexOf(this.config.start_value) < 0
        ) {
            measureInput.start = this.soe_measures[0];
            console.warn(
                this.config.start_value +
                    ' is an invalid measure. Defaulting to ' +
                    measureInput.start +
                    '.'
            );
        } else if (
            this.config.start_value &&
            this.soe_measures.indexOf(this.config.start_value) < 0
        ) {
            measureInput.start = this.soe_measures[this.measures.indexOf(this.config.start_value)];
            console.warn(
                this.config.start_value +
                    ' is missing the units value. Defaulting to ' +
                    measureInput.start +
                    '.'
            );
        } else measureInput.start = this.config.start_value || this.soe_measures[0];
    }

    function removeFilters() {
        var _this = this;

        this.controls.config.inputs = this.controls.config.inputs.filter(function(input) {
            if (input.type !== 'subsetter' || input.value_col === 'soe_measure') {
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

    function updateNormalRangeControl() {
        //If data do not have normal range variables update normal range method setting and options.
        if (
            Object.keys(this.raw_data[0]).indexOf(this.config.normal_col_low) < 0 ||
            Object.keys(this.raw_data[0]).indexOf(this.config.normal_col_high) < 0
        ) {
            if (this.config.normal_range_method === 'LLN-ULN')
                this.config.normal_range_method = 'Standard Deviation';
            this.controls.config.inputs
                .find(function(input) {
                    return input.option === 'normal_range_method';
                })
                .values.splice(1, 1);
        }
    }

    function checkControls() {
        updateMeasureFilter.call(this);
        removeFilters.call(this);
        updateNormalRangeControl.call(this);
    }

    function onInit() {
        // 1. Count number of unique participant IDs in data prior to data cleaning.
        countParticipants.call(this);

        // 2. Remove missing and non-numeric results.
        cleanData.call(this);

        // 3. Define additional variables.
        addVariables.call(this);

        // 4. Define participant, visit, and measure sets.
        defineSets.call(this);

        // 5. Check controls.
        checkControls.call(this);
    }

    function identifyControls() {
        var controlGroups = this.controls.wrap
            .style('padding-bottom', '8px')
            .selectAll('.control-group');

        //Give each control a unique ID.
        controlGroups
            .attr('id', function(d) {
                return d.label.toLowerCase().replace(' ', '-');
            })
            .each(function(d) {
                d3.select(this).classed(d.type, true);
            });

        //Give y-axis controls a common class name.
        controlGroups
            .filter(function(d) {
                return ['y.domain[0]', 'y.domain[1]'].indexOf(d.option) > -1;
            })
            .classed('y-axis', true);

        //Give normal range controls a common class name.
        controlGroups
            .filter(function(d) {
                return (
                    [
                        'normal_range_method',
                        'normal_range_sd',
                        'normal_range_quantile_low',
                        'normal_range_quantile_high'
                    ].indexOf(d.option) > -1
                );
            })
            .classed('normal-range', true);

        //Give visit range controls a common class name.
        controlGroups
            .filter(function(d) {
                return ['visits_without_data', 'unscheduled_visits'].indexOf(d.option) > -1;
            })
            .classed('visits', true);
    }

    function labelXaxisOptions() {
        var _this = this;

        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(d) {
                return d.option === 'x.column';
            })
            .selectAll('option')
            .property('label', function(d) {
                return _this.config.time_cols.find(function(time_col) {
                    return time_col.value_col === d;
                }).label;
            });
    }

    function addYdomainResetButton() {
        var _this = this;

        var resetContainer = this.controls.wrap
            .insert('div', '#lower')
            .classed('control-group y-axis', true)
            .datum({
                type: 'button',
                option: 'y.domain',
                label: ''
            })
            .style('vertical-align', 'bottom');
        var resetLabel = resetContainer
            .append('span')
            .attr('class', 'wc-control-label')
            .text('Limits');
        var resetButton = resetContainer
            .append('button')
            .text(' Reset ')
            .style('padding', '0px 5px')
            .on('click', function() {
                _this.config.y.domain = _this.measure.domain; //reset axis to full range
                _this.draw();
            });
    }

    function insertGrouping(selector, label) {
        var grouping = this.controls.wrap
            .insert('div', selector)
            .style({
                display: 'inline-block',
                'margin-right': '5px'
            })
            .append('fieldset')
            .style('padding', '0px 2px');
        grouping.append('legend').text(label);
        this.controls.wrap.selectAll(selector).each(function(d) {
            this.style.marginTop = '0px';
            this.style.marginRight = '2px';
            this.style.marginBottom = '2px';
            this.style.marginLeft = '2px';
            grouping.node().appendChild(this);
        });
    }

    function groupControls() {
        //Group y-axis controls.
        insertGrouping.call(this, '.y-axis', 'Y-axis');

        //Group filters.
        if (this.filters.length > 1)
            insertGrouping.call(this, '.subsetter:not(#measure)', 'Filters');

        //Group normal controls.
        insertGrouping.call(this, '.normal-range', 'Normal Range');

        //Group visit controls.
        insertGrouping.call(this, '.visits', 'Visits');
    }

    function hideNormalRangeInputs() {
        var _this = this;
        var controls = this.controls.wrap.selectAll('.control-group');

        //Normal range method control
        var normalRangeMethodControl = controls.filter(function(d) {
            return d.label === 'Method';
        });

        //Normal range inputs
        var normalRangeInputs = controls
            .filter(function(d) {
                return (
                    [
                        'normal_range_sd',
                        'normal_range_quantile_low',
                        'normal_range_quantile_high'
                    ].indexOf(d.option) > -1
                );
            })
            .style('display', function(d) {
                return (_this.config.normal_range_method !== 'Standard Deviation' &&
                    d.option === 'normal_range_sd') ||
                    (_this.config.normal_range_method !== 'Quantiles' &&
                        ['normal_range_quantile_low', 'normal_range_quantile_high'].indexOf(
                            d.option
                        ) > -1)
                    ? 'none'
                    : 'inline-table';
            });

        //Set significant digits to .01.
        normalRangeInputs.select('input').attr('step', 0.01);

        normalRangeMethodControl.on('change', function() {
            var normal_range_method = d3
                .select(this)
                .select('option:checked')
                .text();

            normalRangeInputs.style('display', function(d) {
                return (normal_range_method !== 'Standard Deviation' &&
                    d.option === 'normal_range_sd') ||
                    (normal_range_method !== 'Quantiles' &&
                        ['normal_range_quantile_low', 'normal_range_quantile_high'].indexOf(
                            d.option
                        ) > -1)
                    ? 'none'
                    : 'inline-table';
            });
        });
    }

    function addParticipantCountContainer() {
        this.participantCount.container = this.controls.wrap
            .style('position', 'relative')
            .append('div')
            .attr('id', 'participant-count')
            .style({
                position: 'absolute',
                'font-style': 'italic',
                bottom: '-10px',
                left: 0
            });
    }

    function addRemovedRecordsNote() {
        var _this = this;

        if (this.removedRecords.missing > 0 || this.removedRecords.nonNumeric > 0) {
            var message =
                this.removedRecords.missing > 0 && this.removedRecords.nonNumeric > 0
                    ? this.removedRecords.missing +
                      ' record' +
                      (this.removedRecords.missing > 1 ? 's' : '') +
                      ' with a missing result and ' +
                      this.removedRecords.nonNumeric +
                      ' record' +
                      (this.removedRecords.nonNumeric > 1 ? 's' : '') +
                      ' with a non-numeric result were removed.'
                    : this.removedRecords.missing > 0
                      ? this.removedRecords.missing +
                        ' record' +
                        (this.removedRecords.missing > 1 ? 's' : '') +
                        ' with a missing result ' +
                        (this.removedRecords.missing > 1 ? 'were' : 'was') +
                        ' removed.'
                      : this.removedRecords.nonNumeric > 0
                        ? this.removedRecords.nonNumeric +
                          ' record' +
                          (this.removedRecords.nonNumeric > 1 ? 's' : '') +
                          ' with a non-numeric result ' +
                          (this.removedRecords.nonNumeric > 1 ? 'were' : 'was') +
                          ' removed.'
                        : '';
            this.removedRecords.container = this.controls.wrap
                .append('div')
                .style({
                    position: 'absolute',
                    'font-style': 'italic',
                    bottom: '-10px',
                    right: 0
                })
                .text(message);
            this.removedRecords.container
                .append('span')
                .style({
                    color: 'blue',
                    'text-decoration': 'underline',
                    'font-style': 'normal',
                    'font-weight': 'bold',
                    cursor: 'pointer',
                    'font-size': '16px',
                    'margin-left': '5px'
                })
                .html('<sup>x</sup>')
                .on('click', function() {
                    return _this.removedRecords.container.style('display', 'none');
                });
        }
    }

    function addBorderAboveChart() {
        this.wrap.style({
            'border-top': '1px solid #ccc'
        });
    }

    function addSmallMultiplesContainer() {
        this.multiples = {
            container: this.wrap
                .append('div')
                .classed('multiples', true)
                .style({
                    'border-top': '1px solid #ccc',
                    'padding-top': '10px'
                }),
            id: null
        };
    }

    function onLayout() {
        identifyControls.call(this); // Distinguish controls to insert y-axis reset button in the correct position.
        labelXaxisOptions.call(this);
        addYdomainResetButton.call(this);
        groupControls.call(this); // Group related controls visually.
        hideNormalRangeInputs.call(this); // Hide normal range input controls depending on the normal range method.
        addParticipantCountContainer.call(this);
        addRemovedRecordsNote.call(this);
        addBorderAboveChart.call(this);
        addSmallMultiplesContainer.call(this);
    }

    function getCurrentMeasure() {
        this.measure.previous = this.measure.current;
        this.measure.current = this.controls.wrap
            .selectAll('.control-group')
            .filter(function(d) {
                return d.value_col && d.value_col === 'soe_measure';
            })
            .select('option:checked')
            .text();
    }

    function defineMeasureData() {
        var _this = this;

        this.measure.data = this.initial_data.filter(function(d) {
            return d.soe_measure === _this.measure.current;
        });
        this.measure.unit =
            this.config.unit_col && this.measure.data[0].hasOwnProperty(this.config.unit_col)
                ? this.measure.data[0][this.config.unit_col]
                : null;
        this.measure.results = this.measure.data
            .map(function(d) {
                return +d[_this.config.value_col];
            })
            .sort(function(a, b) {
                return a - b;
            });
        this.measure.domain = d3.extent(this.measure.results);
        this.measure.range = this.measure.domain[1] - this.measure.domain[0];
        this.measure.log10range = Math.log10(this.measure.range);
        this.raw_data = this.measure.data.filter(function(d) {
            return _this.config.unscheduled_visits || !d.unscheduled;
        });
    }

    function removeVisitsWithoutData() {
        var _this = this;

        if (!this.config.visits_without_data)
            this.config.x.domain = this.config.x.domain.filter(function(visit) {
                return (
                    d3
                        .set(
                            _this.raw_data.map(function(d) {
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
        }
    }

    function setXdomain() {
        var _this = this;

        //Attach the time settings object to the x-axis settings object.
        this.config.time_settings = this.config.time_cols.find(function(time_col) {
            return time_col.value_col === _this.config.x.column;
        });
        Object.assign(this.config.x, this.config.time_settings);

        //When the domain is not specified, it's calculated on data transform.
        if (this.config.x.type === 'linear') {
            delete this.config.x.domain;
            delete this.config.x.order;
        }

        //Remove unscheduled visits from x-domain if x-type is ordinal.
        if (this.config.x.type === 'ordinal') {
            removeVisitsWithoutData.call(this);
            removeUnscheduledVisits.call(this);
        }
    }

    function setYdomain() {
        if (this.measure.current !== this.measure.previous)
            this.config.y.domain = this.measure.domain;
        else if (this.config.y.domain[0] > this.config.y.domain[1])
            // reset y-domain
            this.config.y.domain.reverse(); // reverse y-domain
    }

    function calculateYPrecision() {
        //define the precision of the y-axis
        this.config.y.precisionFactor = Math.round(this.measure.log10range);
        this.config.y.precision = Math.pow(10, this.config.y.precisionFactor);
        this.config.y.format =
            this.config.y.precisionFactor > 0
                ? '.0f'
                : '.' + (Math.abs(this.config.y.precisionFactor) + 1) + 'f';

        //define the size of the y-axis limit increments
        var step =
            this.measure.range > 0
                ? Math.abs(this.measure.range / 15) // non-zero range
                : this.measure.results[0] !== 0
                  ? Math.abs(this.measure.results[0] / 15) // zero range, non-zero result(s)
                  : 1; // zero range, zero result(s)
        if (step < 1) {
            var x10 = 0;
            do {
                step = step * 10;
                ++x10;
            } while (step < 1);
            step = Math.round(step) / Math.pow(10, x10);
        } else step = Math.round(step);
        this.measure.step = step || 1;
    }

    function updateYaxisLimitControls() {
        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(f) {
                return f.option === 'y.domain[0]';
            })
            .select('input')
            .attr('step', this.measure.step) // set in ./calculateYPrecision
            .style('box-shadow', 'none')
            .property('value', this.config.y.domain[0]);

        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(f) {
                return f.option === 'y.domain[1]';
            })
            .select('input')
            .attr('step', this.measure.step) // set in ./calculateYPrecision
            .style('box-shadow', 'none')
            .property('value', this.config.y.domain[1]);
    }

    function setYaxisLabel() {
        this.config.y.label = this.measure.current;
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

    function deriveStatistics() {
        var _this = this;

        if (this.config.normal_range_method === 'LLN-ULN') {
            this.lln = function(d) {
                return d instanceof Object
                    ? +d[_this.config.normal_col_low]
                    : d3.median(_this.measure.data, function(d) {
                          return +d[_this.config.normal_col_low];
                      });
            };
            this.uln = function(d) {
                return d instanceof Object
                    ? +d[_this.config.normal_col_high]
                    : d3.median(_this.measure.data, function(d) {
                          return +d[_this.config.normal_col_high];
                      });
            };
        } else if (this.config.normal_range_method === 'Standard Deviation') {
            this.mean = d3.mean(this.measure.results);
            this.sd = d3.deviation(this.measure.results);
            this.lln = function() {
                return _this.mean - _this.config.normal_range_sd * _this.sd;
            };
            this.uln = function() {
                return _this.mean + _this.config.normal_range_sd * _this.sd;
            };
        } else if (this.config.normal_range_method === 'Quantiles') {
            this.lln = function() {
                return d3.quantile(_this.measure.results, _this.config.normal_range_quantile_low);
            };
            this.uln = function() {
                return d3.quantile(_this.measure.results, _this.config.normal_range_quantile_high);
            };
        } else {
            this.lln = function(d) {
                return d instanceof Object
                    ? d[_this.config.value_col] + 1
                    : _this.measure.results[0];
            };
            this.uln = function(d) {
                return d instanceof Object
                    ? d[_this.config.value_col] - 1
                    : _this.measure.results[_this.measure.results.length - 1];
            };
        }
    }

    function onPreprocess() {
        // 1. Capture currently selected measure.
        getCurrentMeasure.call(this);

        // 2. Filter data on currently selected measure.
        defineMeasureData.call(this);

        // 3a Set x-domain given current visit settings.
        setXdomain.call(this);

        // 3b Set y-domain given currently selected measure.
        setYdomain.call(this);

        // 3c Calculate precision of y-domain.
        calculateYPrecision.call(this);

        // 3c Set y-axis label to current measure.
        setYaxisLabel.call(this);

        // 4a Update y-axis reset button when measure changes.
        updateYaxisResetButton.call(this);

        // 4b Update y-axis limit controls to match y-axis domain.
        updateYaxisLimitControls.call(this);

        // 4c Define normal range statistics.
        deriveStatistics.call(this);
    }

    function onDatatransform() {}

    function updateParticipantCount() {
        var _this = this;

        //count the number of unique ids in the current chart and calculate the percentage
        this.participantCount.n = d3
            .set(
                this.filtered_data.map(function(d) {
                    return d[_this.config.id_col];
                })
            )
            .values().length;
        this.participantCount.percentage = d3.format('0.1%')(
            this.participantCount.n / this.participantCount.N
        );

        //clear the annotation
        this.participantCount.container.selectAll('*').remove();

        //update the annotation
        this.participantCount.container.text(
            '\n' +
                this.participantCount.n +
                ' of ' +
                this.participantCount.N +
                ' participant(s) shown (' +
                this.participantCount.percentage +
                ')'
        );
    }

    function resetChart() {
        this.svg.selectAll('.line,.point').remove();
        //delete this.hovered_id;
        //delete this.selected_id;
        //if (this.multiples.chart)
        //    this.multiples.chart.destroy();
    }

    function extendYDomain() {
        if (
            this.config.y.domain[0] === this.measure.domain[0] &&
            this.config.y.domain[1] === this.measure.domain[1] &&
            this.config.y.domain[0] < this.measure.domain[1]
        )
            this.y_dom = [
                this.config.y.domain[0] - this.measure.range * 0.01,
                this.config.y.domain[1] + this.measure.range * 0.01
            ];
    }

    function updateBottomMargin() {
        this.config.margin.bottom = this.config.x.vertical_space;
    }

    function onDraw() {
        //Annotate participant count.
        updateParticipantCount.call(this);

        //Clear current multiples.
        resetChart.call(this);

        //Extend y-domain to avoid obscuring minimum and maximum points.
        extendYDomain.call(this);

        //Update bottom margin for tick label rotation.
        updateBottomMargin.call(this);
    }

    function attachMarks() {
        this.marks.forEach(function(mark) {
            mark.groups.each(function(group) {
                group.attributes = mark.attributes;
                if (mark.type === 'circle') group.radius = mark.radius;
            });
        });
        this.lines = this.svg.selectAll('.line');
        this.points = this.svg.selectAll('.point');
    }

    function highlightSelected() {
        var _this = this;

        //Add _selected_ class to participant's marks.
        this.marks.forEach(function(mark) {
            mark.groups.classed('selected', function(d) {
                return mark.type === 'line'
                    ? d.values[0].values.raw[0][_this.config.id_col] === _this.selected_id
                    : d.values.raw[0][_this.config.id_col] === _this.selected_id;
            });
        });

        //Update attributes of selected line.
        this.lines
            .filter(function(d) {
                return d.values[0].values.raw[0][_this.config.id_col] === _this.selected_id;
            })
            .select('path')
            .attr('stroke-width', function(d) {
                return d.attributes['stroke-width'] * 8;
            });

        //Update attributes of selected points.
        this.points
            .filter(function(d) {
                return d.values.raw[0][_this.config.id_col] === _this.selected_id;
            })
            .select('circle')
            .attr({
                r: function r(d) {
                    return d.radius * 1.5;
                },
                stroke: 'black',
                'stroke-width': function strokeWidth(d) {
                    return d.attributes['stroke-width'] * 8;
                }
            });
    }

    function maintainHighlight() {
        if (this.selected_id) highlightSelected.call(this);
    }

    function drawNormalRange() {
        if (this.normalRange) this.normalRange.remove();

        if (this.config.normal_range_method) {
            this.normalRange = this.svg
                .insert('g', '.line-supergroup')
                .classed('normal-range', true);
            this.normalRange
                .append('rect')
                .attr({
                    x: 0,
                    y: this.y(this.uln()),
                    width: this.plot_width,
                    height: this.y(this.lln()) - this.y(this.uln()),
                    'clip-path': 'url(#' + this.id + ')'
                })
                .style({
                    fill: 'blue',
                    'fill-opacity': 0.1
                });
            this.normalRange.append('title').text('Normal range: ' + this.lln() + '-' + this.uln());
        }
    }

    function orderPoints() {
        var _this = this;

        this.marks
            .filter(function(mark) {
                return mark.type === 'circle';
            })
            .forEach(function(mark) {
                mark.groups.each(function(d, i) {
                    d.order = _this.IDOrder.find(function(di) {
                        return d.key.indexOf(di.ID) === 0;
                    }).order;
                });
            });
    }

    function clearHovered() {
        this.lines
            .filter(function() {
                return !d3.select(this).classed('selected');
            })
            .select('path')
            .each(function(d) {
                d3.select(this).attr(d.attributes);
            });
        this.points
            .filter(function() {
                return !d3.select(this).classed('selected');
            })
            .select('circle')
            .each(function(d) {
                d3.select(this).attr(d.attributes);
                d3.select(this).attr('r', d.radius);
            });
        delete this.hovered_id;
    }

    function clearSelected() {
        this.marks.forEach(function(mark) {
            var element = mark.type === 'line' ? 'path' : mark.type;
            mark.groups
                .classed('selected', false)
                .select(element)
                .attr(mark.attributes);
        });
        if (this.multiples.chart) this.multiples.chart.destroy();
        delete this.selected_id;
    }

    function addOverlayEventListener() {
        var _this = this;

        this.overlay
            .on('mouseover', function() {
                clearHovered.call(_this);
            })
            .on('click', function() {
                clearHovered.call(_this);
                clearSelected.call(_this);
            });
    }

    function addOverlayEventListener$1() {
        var _this = this;

        this.normalRange
            .on('mouseover', function() {
                clearHovered.call(_this);
            })
            .on('click', function() {
                clearHovered.call(_this);
                clearSelected.call(_this);
            });
    }

    function highlightHovered() {
        var _this = this;

        //Update attributes of hovered line.
        this.lines
            .filter(function(d) {
                return d.values[0].values.raw[0][_this.config.id_col] === _this.hovered_id;
            })
            .select('path')
            .attr('stroke-width', function(d) {
                return d.attributes['stroke-width'] * 4;
            });

        //Update attributes of hovered points.
        this.points
            .filter(function(d) {
                return d.values.raw[0][_this.config.id_col] === _this.hovered_id;
            })
            .select('circle')
            .attr({
                r: function r(d) {
                    return d.radius * 1.25;
                },
                stroke: 'black',
                'stroke-width': function strokeWidth(d) {
                    return d.attributes['stroke-width'] * 4;
                }
            });
    }

    function reorderMarks() {
        var _this = this;

        //Move selected line behind all other lines.
        this.lines
            .each(function(d, i) {
                if (d.key.indexOf(_this.selected_id) === 0) d.order = _this.IDOrder.length - 1;
                else if (d.order > _this.selected_id_order) d.order = d.order - 1;
            })
            .sort(function(a, b) {
                return b.order - a.order;
            });

        //Move selected points behind all other points.
        this.points
            .each(function(d, i) {
                if (d.key.indexOf(_this.selected_id) === 0) d.order = _this.IDOrder.length - 1;
                else if (d.order > _this.selected_id_order) d.order = d.order - 1;
            })
            .sort(function(a, b) {
                return b.order - a.order;
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

    function defineSmallMultiples() {
        //Define small multiples settings.
        this.multiples.settings = Object.assign(
            {},
            clone(this.config),
            clone(Object.getPrototypeOf(this.config))
        );
        this.multiples.settings.x.domain = null;
        this.multiples.settings.y.domain = null;
        this.multiples.settings.resizable = false;
        this.multiples.settings.scale_text = false;

        if (this.multiples.settings.multiples_sizing.width)
            this.multiples.settings.width = this.multiples.settings.multiples_sizing.width;
        if (this.multiples.settings.multiples_sizing.height)
            this.multiples.settings.height =
                this.multiples.settings.multiples_sizing.height +
                (this.multiples.settings.margin.bottom ? this.multiples.settings.margin.bottom : 0);

        this.multiples.settings.margin = { bottom: this.multiples.settings.margin.bottom || 20 };

        //Add participant dropdown.
        this.multiples.settings.selected_id = this.selected_id;
        this.multiples.controls = webcharts.createControls(this.multiples.container.node(), {
            inputs: [
                {
                    type: 'dropdown',
                    label: 'All Measures for',
                    option: 'selected_id',
                    values: this.IDOrder.map(function(d) {
                        return d.ID;
                    }),
                    require: true
                }
            ]
        });

        //Initialize small multiples.
        this.multiples.chart = webcharts.createChart(
            this.multiples.container.node(),
            this.multiples.settings,
            this.multiples.controls
        );
        this.multiples.chart.safetyOutlierExplorer = this;
    }

    function participantCharacteristics() {
        var _this = this;

        this.multiples.detail_table = this.multiples.chart.wrap
            .insert('table', '.legend')
            .append('tbody')
            .classed('detail-listing', true);
        this.multiples.detail_table
            .append('thead')
            .selectAll('th')
            .data(['', ''])
            .enter()
            .append('th');
        this.multiples.detail_table.append('tbody');

        //Insert a line for each item in [ settings.detail_cols ].
        if (Array.isArray(this.config.details) && this.config.details.length) {
            var participantDatum = this.multiples.data[0];
            this.config.details.forEach(function(detail) {
                var value_col = detail.value_col ? detail.value_col : detail;
                var label = detail.label
                    ? detail.label
                    : detail.value_col ? detail.value_col : detail;
                var tuple = [label, participantDatum[value_col]];

                if (tuple[1] !== undefined)
                    _this.multiples.detail_table
                        .select('tbody')
                        .append('tr')
                        .selectAll('td')
                        .data(tuple)
                        .enter()
                        .append('td')
                        .style('text-align', function(d, i) {
                            return i === 0 ? 'right' : 'left';
                        })
                        .text(function(d, i) {
                            return i === 0 ? d + ':' : d;
                        });
            });
        }
    }

    function onLayout$1() {
        this.multiples.chart.on('layout', function() {
            //Define multiple styling.
            this.wrap.style('display', 'block');
            this.wrap
                .selectAll('.wc-chart-title')
                .style('display', 'block')
                .style('border-top', '1px solid #eee');
            this.wrap.selectAll('.wc-chart').style('padding-bottom', '2px');

            //Set y-label to measure unit.
            this.config.y.label = '';

            //Outline currently selected measure.
            //if (this.filters[0].val === this.parent.safetyOutlierExplorer.measure.current)
            //    this.wrap
            //        .select('.wc-chart-title')
            //        .append('span')
            //        .html(' &#9432;')
            //        .style({
            //            'font-weight': 'bold',
            //            'cursor': 'default',
            //        })
            //        .attr('title', 'Currently selected measure');
        });
    }

    function onPreprocess$1() {
        this.multiples.chart.on('preprocess', function() {
            var _this = this;

            //Define y-domain as minimum of lower limit of normal and minimum result and maximum of
            //upper limit of normal and maximum result.
            var filtered_data = this.raw_data.filter(function(f) {
                return f[_this.filters[0].col] === _this.filters[0].val;
            });

            //Calculate range of normal range.
            var normlo = Math.min.apply(
                null,
                filtered_data
                    .map(function(m) {
                        return +m[_this.config.normal_col_low];
                    })
                    .filter(function(f) {
                        return +f || +f === 0;
                    })
            );
            var normhi = Math.max.apply(
                null,
                filtered_data
                    .map(function(m) {
                        return +m[_this.config.normal_col_high];
                    })
                    .filter(function(f) {
                        return +f || +f === 0;
                    })
            );

            //Calculate range of data.
            var ylo = d3.min(
                filtered_data
                    .map(function(m) {
                        return +m[_this.config.y.column];
                    })
                    .filter(function(f) {
                        return +f || +f === 0;
                    })
            );
            var yhi = d3.max(
                filtered_data
                    .map(function(m) {
                        return +m[_this.config.y.column];
                    })
                    .filter(function(f) {
                        return +f || +f === 0;
                    })
            );

            //Set y-domain.
            this.config.y_dom = [Math.min(normlo, ylo), Math.max(normhi, yhi)];
        });
    }

    function adjustTicks() {
        if (this.config.x.rotate_tick_labels)
            this.svg
                .selectAll('.x.axis .tick text')
                .attr({
                    transform: 'rotate(-45)',
                    dx: -10,
                    dy: 10
                })
                .style('text-anchor', 'end');
    }

    function rangePolygon() {
        var _this = this;

        var area = d3.svg
            .area()
            .x(function(d) {
                return (
                    _this.x(d['TIME']) +
                    (_this.config.x.type === 'ordinal' ? _this.x.rangeBand() / 2 : 0)
                );
            })
            .y0(function(d) {
                return /^-?[0-9.]+$/.test(d[_this.config.normal_col_low])
                    ? _this.y(d[_this.config.normal_col_low])
                    : 0;
            })
            .y1(function(d) {
                return /^-?[0-9.]+$/.test(d[_this.config.normal_col_high])
                    ? _this.y(d[_this.config.normal_col_high])
                    : 0;
            });

        var dRow = this.filtered_data[0];

        var myRows = this.x_dom.slice().map(function(m) {
            return {
                STNRLO: dRow[_this.config.normal_col_low],
                STNRHI: dRow[_this.config.normal_col_high],
                TIME: m
            };
        });

        //remove what is there now
        this.svg.select('.norms').remove();

        //add new
        var normalRange = this.svg
            .append('g')
            .datum(myRows)
            .attr('class', 'norms');
        normalRange
            .append('path')
            .attr('fill', 'blue')
            .attr('fill-opacity', 0.1)
            .attr('d', area);
        normalRange.append('title').text(function(d) {
            return 'Normal range: ' + d[0].STNRLO + '-' + d[0].STNRHI;
        });
    }

    function onResize() {
        this.multiples.chart.on('resize', function() {
            //Resize text manually.
            this.wrap.select('.wc-chart-title').style('font-size', '12px');
            this.svg.selectAll('.axis .tick text').style('font-size', '10px');

            //Draw normal range.
            if (this.filtered_data.length) rangePolygon.call(this);

            //Axis tweaks
            this.svg
                .select('.x.axis')
                .select('.axis-title')
                .remove();

            //Delete legend.
            this.legend.remove();

            //Rotate ticks.
            adjustTicks.call(this);
        });
    }

    function updateParticipantDropdown() {
        var context = this; // chart

        var participantDropdown = this.multiples.controls.wrap
            .style('margin', 0)
            .selectAll('.control-group')
            .filter(function(d) {
                return d.option === 'selected_id';
            })
            .style('margin', 0)
            .style('display', 'block'); // firefox is being weird about inline-table
        participantDropdown.selectAll('*').style('display', 'inline-block');
        participantDropdown.selectAll('.wc-control-label').style('font-weight', 'bold');
        participantDropdown
            .selectAll('select')
            .style('margin-left', '3px')
            .style('width', null)
            .style('max-width', '10%')
            .on('change', function(d) {
                context.multiples.id = d3
                    .select(this)
                    .selectAll('option:checked')
                    .text();
                clearSelected.call(context);
                context.selected_id = context.multiples.id;
                highlightSelected.call(context);
                smallMultiples.call(context);
            });
    }

    function smallMultiples() {
        var _this = this;

        //Define participant data.
        this.multiples.data = this.initial_data.filter(function(d) {
            return d[_this.config.id_col] === _this.selected_id;
        });

        //Define small multiples.
        defineSmallMultiples.call(this);

        //Insert participant characteristics table.
        participantCharacteristics.call(this);

        //Add callbacks to small multiples.
        onLayout$1.call(this);
        onPreprocess$1.call(this);
        onResize.call(this);

        //Initialize small multiples.
        webcharts.multiply(this.multiples.chart, this.multiples.data, 'soe_measure', this.measures);

        //Update participant dropdown.
        updateParticipantDropdown.call(this);
    }

    function addLineEventListeners() {
        var _this = this;

        this.lines
            .on('mouseover', function(d) {
                clearHovered.call(_this);
                _this.hovered_id = d.values[0].values.raw[0][_this.config.id_col];
                if (_this.hovered_id !== _this.selected_id) highlightHovered.call(_this);
            })
            .on('mouseout', function(d) {
                clearHovered.call(_this);
            })
            .on('click', function(d) {
                clearHovered.call(_this);
                clearSelected.call(_this);
                _this.selected_id = d.values[0].values.raw[0][_this.config.id_col];
                _this.selected_id_order = _this.IDOrder.find(function(di) {
                    return di.ID === _this.selected_id;
                }).order;
                highlightSelected.call(_this);
                reorderMarks.call(_this);
                smallMultiples.call(_this);
            });
    }

    function addPointEventListeners() {
        var _this = this;

        this.points
            .on('mouseover', function(d) {
                clearHovered.call(_this);
                _this.hovered_id = d.values.raw[0][_this.config.id_col];
                if (_this.hovered_id !== _this.selected_id) highlightHovered.call(_this);
            })
            .on('mouseout', function(d) {
                clearHovered.call(_this);
            })
            .on('click', function(d) {
                clearHovered.call(_this);
                clearSelected.call(_this);
                _this.selected_id = d.values.raw[0][_this.config.id_col];
                _this.selected_id_order = _this.IDOrder.find(function(di) {
                    return di.ID === _this.selected_id;
                }).order;
                highlightSelected.call(_this);
                reorderMarks.call(_this);
                smallMultiples.call(_this);
            });
    }

    function addEventListeners() {
        addOverlayEventListener.call(this);
        addOverlayEventListener$1.call(this);
        addLineEventListeners.call(this);
        addPointEventListeners.call(this);
    }

    function addBoxPlot() {
        //Clear box plot.
        this.svg.select('g.boxplot').remove();

        //Customize box plot.
        var svg = this.svg;
        var results = this.current_data
            .map(function(d) {
                return +d.values.y;
            })
            .sort(d3.ascending);
        var height = this.plot_height;
        var width = 1;
        var domain = this.y_dom;
        var boxPlotWidth = 10;
        var boxColor = '#bbb';
        var boxInsideColor = 'white';
        var fmt = d3.format('.3r');

        //set up scales
        var x = d3.scale.linear().range([0, width]);
        var y = d3.scale.linear().range([height, 0]);

        {
            y.domain(domain);
        }

        var probs = [0.05, 0.25, 0.5, 0.75, 0.95];
        for (var i = 0; i < probs.length; i++) {
            probs[i] = d3.quantile(results, probs[i]);
        }

        var boxplot = this.svg
            .append('g')
            .attr('class', 'boxplot')
            .datum({
                values: results,
                probs: probs
            })
            .attr(
                'transform',
                'translate(' + (this.plot_width + this.config.margin.right / 2) + ',0)'
            );

        //draw rectangle from q1 to q3
        var box_x = x(0.5 - boxPlotWidth / 2);
        var box_width = x(0.5 + boxPlotWidth / 2) - x(0.5 - boxPlotWidth / 2);
        var box_y = y(probs[3]);
        var box_height = -y(probs[3]) + y(probs[1]);

        boxplot
            .append('rect')
            .attr('class', 'boxplot fill')
            .attr('x', box_x)
            .attr('width', box_width)
            .attr('y', box_y)
            .attr('height', box_height)
            .style('fill', boxColor);

        //draw dividing lines at median, 95% and 5%
        var iS = [0, 2, 4];
        var iSclass = ['', 'median', ''];
        var iSColor = [boxColor, boxInsideColor, boxColor];
        for (var i = 0; i < iS.length; i++) {
            boxplot
                .append('line')
                .attr('class', 'boxplot ' + iSclass[i])
                .attr('x1', x(0.5 - boxPlotWidth / 2))
                .attr('x2', x(0.5 + boxPlotWidth / 2))
                .attr('y1', y(probs[iS[i]]))
                .attr('y2', y(probs[iS[i]]))
                .style('fill', iSColor[i])
                .style('stroke', iSColor[i]);
        }

        //draw lines from 5% to 25% and from 75% to 95%
        var iS = [[0, 1], [3, 4]];
        for (var i = 0; i < iS.length; i++) {
            boxplot
                .append('line')
                .attr('class', 'boxplot')
                .attr('x1', x(0.5))
                .attr('x2', x(0.5))
                .attr('y1', y(probs[iS[i][0]]))
                .attr('y2', y(probs[iS[i][1]]))
                .style('stroke', boxColor);
        }

        boxplot
            .append('circle')
            .attr('class', 'boxplot mean')
            .attr('cx', x(0.5))
            .attr('cy', y(d3.mean(results)))
            .attr('r', x(boxPlotWidth / 3))
            .style('fill', boxInsideColor)
            .style('stroke', boxColor);

        boxplot
            .append('circle')
            .attr('class', 'boxplot mean')
            .attr('cx', x(0.5))
            .attr('cy', y(d3.mean(results)))
            .attr('r', x(boxPlotWidth / 6))
            .style('fill', boxColor)
            .style('stroke', 'None');

        boxplot.append('title').text(function(d) {
            var tooltip =
                'N = ' +
                d.values.length +
                '\n' +
                'Min = ' +
                d3.min(d.values) +
                '\n' +
                '5th % = ' +
                fmt(d3.quantile(d.values, 0.05)).replace(/^ */, '') +
                '\n' +
                'Q1 = ' +
                fmt(d3.quantile(d.values, 0.25)).replace(/^ */, '') +
                '\n' +
                'Median = ' +
                fmt(d3.median(d.values)).replace(/^ */, '') +
                '\n' +
                'Q3 = ' +
                fmt(d3.quantile(d.values, 0.75)).replace(/^ */, '') +
                '\n' +
                '95th % = ' +
                fmt(d3.quantile(d.values, 0.95)).replace(/^ */, '') +
                '\n' +
                'Max = ' +
                d3.max(d.values) +
                '\n' +
                'Mean = ' +
                fmt(d3.mean(d.values)).replace(/^ */, '') +
                '\n' +
                'StDev = ' +
                fmt(d3.deviation(d.values)).replace(/^ */, '');
            return tooltip;
        });
    }

    function onResize$1() {
        //Attach mark groups to central chart object.
        attachMarks.call(this);

        //Maintain mark highlighting.
        maintainHighlight.call(this);

        //Draw normal range.
        drawNormalRange.call(this);

        //Add initial ordering to points; ordering will update as points are clicked.
        orderPoints.call(this);

        //Add event listeners to lines, points, and overlay.
        addEventListeners.call(this);

        //Draw a marginal box plot.
        addBoxPlot.call(this);

        //Rotate tick marks to prevent text overlap.
        adjustTicks.call(this);
    }

    function onDestroy() {}

    var callbacks = {
        onInit: onInit,
        onLayout: onLayout,
        onPreprocess: onPreprocess,
        onDatatransform: onDatatransform,
        onDraw: onDraw,
        onResize: onResize$1,
        onDestroy: onDestroy
    };

    function safetyOutlierExplorer(element, settings) {
        //Merge user settings with default settings.
        var mergedSettings = Object.assign({}, configuration.settings, settings);

        //Sync options within settings object, e.g. data mappings.
        var syncedSettings = configuration.syncSettings(mergedSettings);

        //Sync control inputs with with settings object.
        var syncedControlInputs = configuration.syncControlInputs(
            configuration.controlInputs(),
            syncedSettings
        );

        //Define controls.
        var controls = webcharts.createControls(element, {
            location: 'top',
            inputs: syncedControlInputs
        });

        //Define chart.
        var chart = webcharts.createChart(element, syncedSettings, controls);
        chart.config.marks.forEach(function(mark) {
            mark.attributes = mark.attributes || {};
            mark.attributes['clip-path'] = 'url(#' + chart.id + ')';
        });

        //Attach callbacks to chart.
        for (var callback in callbacks) {
            chart.on(callback.substring(2).toLowerCase(), callbacks[callback]);
        }
        return chart;
    }

    return safetyOutlierExplorer;
});
