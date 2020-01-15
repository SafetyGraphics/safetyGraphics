(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined'
        ? (module.exports = factory(require('d3'), require('webcharts')))
        : typeof define === 'function' && define.amd
            ? define(['d3', 'webcharts'], factory)
            : ((global = global || self),
                (global.safetyDeltaDelta = factory(global.d3, global.webCharts)));
})(this, function (d3, webcharts) {
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

    Math.log10 = Math.log10 =
        Math.log10 ||
        function (x) {
            return Math.log(x) * Math.LOG10E;
        };

    // https://github.com/wbkd/d3-extended
    d3.selection.prototype.moveToFront = function () {
        return this.each(function () {
            this.parentNode.appendChild(this);
        });
    };

    d3.selection.prototype.moveToBack = function () {
        return this.each(function () {
            var firstChild = this.parentNode.firstChild;
            if (firstChild) {
                this.parentNode.insertBefore(this, firstChild);
            }
        });
    };

    function rendererSettings() {
        return {
            id_col: 'USUBJID',
            visit_col: 'VISIT',
            visitn_col: 'VISITNUM',
            measure_col: 'TEST',
            value_col: 'STRESN',
            filters: null,
            details: null,
            measure: {
                x: null,
                y: null
            },
            visits: {
                baseline: [],
                comparison: [],
                stat: 'mean'
            },
            add_regression_line: true
        };
    }

    function webchartsSettings() {
        return {
            x: {
                column: null,
                type: 'linear',
                label: 'x delta',
                format: '0.2f'
            },
            y: {
                column: null,
                type: 'linear',
                label: 'y delta',
                behavior: 'flex',
                format: '0.2f'
            },
            marks: [
                {
                    type: 'circle',
                    per: null,
                    radius: 4,
                    attributes: {
                        'stroke-width': 0.5,
                        'fill-opacity': 0.8
                    },
                    tooltip:
                        'Subject ID: [key]\nX Delta: [delta_x_rounded]\nY Delta: [delta_y_rounded]'
                }
            ],
            gridlines: 'xy',
            resizable: false,
            margin: { right: 25, top: 25 },
            aspect: 1,
            width: 400
        };
    }

    function syncSettings(settings) {
        //handle a string argument to filters
        if (!(settings.filters instanceof Array))
            settings.filters = typeof settings.filters === 'string' ? [settings.filters] : [];

        //handle a string argument to details
        if (!(settings.details instanceof Array))
            settings.details = typeof settings.details === 'string' ? [settings.details] : [];

        //Define default details.
        var defaultDetails = [{ value_col: settings.id_col, label: 'Participant ID' }];
        if (Array.isArray(settings.filters))
            settings.filters
                .filter(function (filter) {
                    return filter.value_col !== settings.id_col;
                })
                .forEach(function (filter) {
                    return defaultDetails.push({
                        value_col: filter.value_col ? filter.value_col : filter,
                        label: filter.label
                            ? filter.label
                            : filter.value_col
                                ? filter.value_col
                                : filter
                    });
                });

        //If [settings.details] is not specified:
        if (!settings.details) settings.details = defaultDetails;
        else {
            //If [settings.details] is specified:
            //Allow user to specify an array of columns or an array of objects with a column property
            //and optionally a column label.
            settings.details.forEach(function (detail) {
                if (
                    defaultDetails
                        .map(function (d) {
                            return d.value_col;
                        })
                        .indexOf(detail.value_col ? detail.value_col : detail) === -1
                )
                    defaultDetails.push({
                        value_col: detail.value_col ? detail.value_col : detail,
                        label: detail.label
                            ? detail.label
                            : detail.value_col
                                ? detail.value_col
                                : detail
                    });
            });
            settings.details = defaultDetails;
        }

        return settings;
    }

    function controlInputs() {
        return [
            {
                type: 'dropdown',
                values: [],
                label: 'Baseline visit(s)',
                option: 'visits.baseline',
                require: true,
                multiple: true
            },
            {
                type: 'dropdown',
                values: [],
                label: 'Comparison visit(s)',
                option: 'visits.comparison',
                require: true,
                multiple: true
            },
            {
                type: 'dropdown',
                values: [],
                label: 'X Measure',
                option: 'measure.x',
                require: true
            },
            {
                type: 'dropdown',
                values: [],
                label: 'Y Measure',
                option: 'measure.y',
                require: true
            }
        ];
    }

    function syncControlInputs(controlInputs, settings) {
        //Add filters to default controls.
        if (Array.isArray(settings.filters) && settings.filters.length > 0) {
            settings.filters.forEach(function (filter) {
                var filterObj = {
                    type: 'subsetter',
                    value_col: filter.value_col || filter,
                    label: filter.label || filter.value_col || filter
                };
                controlInputs.push(filterObj);
            });
        } else delete settings.filters;
        return controlInputs;
    }

    function listingSettings() {
        return {
            cols: ['key', 'spark', 'delta'],
            headers: ['Measure', '', 'Change over Time'],
            searchable: false,
            sortable: false,
            pagination: false,
            exportable: false
        };
    }

    var configuration = {
        rendererSettings: rendererSettings,
        webchartsSettings: webchartsSettings,
        settings: Object.assign({}, rendererSettings(), webchartsSettings()),
        syncSettings: syncSettings,
        controlInputs: controlInputs,
        syncControlInputs: syncControlInputs,
        listingSettings: listingSettings
    };

    function cleanData() {
        var _this = this;

        //Remove missing and non-numeric data.
        var preclean = this.raw_data;
        var clean = this.raw_data.filter(function (d) {
            return /^-?[0-9.]+$/.test(d[_this.config.value_col]);
        });
        var nPreclean = preclean.length;
        var nClean = clean.length;
        var nRemoved = nPreclean - nClean;

        //Warn user of removed records.
        if (nRemoved > 0)
            console.warn(
                nRemoved +
                ' missing or non-numeric result' +
                (nRemoved > 1 ? 's have' : ' has') +
                ' been removed.'
            );

        //Preserve cleaned data.
        this.initial_data = clean;
    }

    function trimMeasures() {
        var _this = this;

        this.initial_data.forEach(function (d) {
            d[_this.config.measure_col] = d[_this.config.measure_col].trim();
        });
    }

    function checkFilters() {
        var _this = this;

        if (this.config.filters)
            this.config.filters = this.config.filters.filter(function (filter) {
                var variableExists = _this.raw_data[0].hasOwnProperty(filter.value_col);
                var nLevels = d3
                    .set(
                        _this.raw_data.map(function (d) {
                            return d[filter.value_col];
                        })
                    )
                    .values().length;

                if (!variableExists)
                    console.warn(
                        ' The [ ' +
                        filter.label +
                        ' ] filter has been removed because the variable does not exist.'
                    );
                else if (nLevels < 2)
                    console.warn(
                        'The [ ' +
                        filter.label +
                        ' ] filter has been removed because the variable has only one level.'
                    );

                return variableExists && nLevels > 1;
            });
    }

    function getMeasures() {
        var _this = this;

        this.measures = d3
            .set(
                this.initial_data.map(function (d) {
                    return d[_this.config.measure_col];
                })
            )
            .values()
            .sort();
    }

    function getVisits() {
        var _this = this;

        if (this.config.visitn_col && this.initial_data[0].hasOwnProperty(this.config.visitn_col))
            this.visits = d3
                .set(
                    this.initial_data.map(function (d) {
                        return d[_this.config.visit_col] + '||' + d[_this.config.visitn_col];
                    })
                )
                .values()
                .sort(function (a, b) {
                    var aSplit = a.split('||');
                    var aVisit = aSplit[0];
                    var aOrder = aSplit[1];
                    var bSplit = b.split('||');
                    var bVisit = bSplit[0];
                    var bOrder = bSplit[1];
                    var diff = aOrder - bOrder;
                    return diff
                        ? diff
                        : aOrder < bOrder
                            ? -1
                            : aOrder > bOrder
                                ? 1
                                : aVisit < bVisit
                                    ? -1
                                    : 1;
                })
                .map(function (visit) {
                    return visit.split('||')[0];
                });
        else
            this.visits = d3
                .set(
                    this.initial_data.map(function (d) {
                        return d[_this.config.visit_col];
                    })
                )
                .values()
                .sort();
    }

    function updateControlInputs() {
        var x_control = this.controls.config.inputs.find(function (input) {
            return input.option === 'measure.x';
        });
        x_control.values = this.measures;
        x_control.start = this.config.measure.x;

        var y_control = this.controls.config.inputs.find(function (input) {
            return input.option === 'measure.y';
        });
        y_control.values = this.measures;
        y_control.start = this.config.measure.y;

        var baseline_control = this.controls.config.inputs.find(function (input) {
            return input.option === 'visits.baseline';
        });
        baseline_control.values = this.visits;
        baseline_control.start = this.config.visits.baseline;

        var comparison_control = this.controls.config.inputs.find(function (input) {
            return input.option === 'visits.comparison';
        });
        comparison_control.values = this.visits;
        comparison_control.start = this.config.visits.comprarison;
    }

    function initCustomEvents() {
        var chart = this;
        chart.participantsSelected = [];
        chart.events.participantsSelected = new CustomEvent('participantsSelected');
    }

    function initSettings() {
        //Set initial measures.
        this.config.measure.x = this.config.measure.x || this.measures[0];

        //  this.config.x.column = this.config.measure.x;
        this.config.measure.y = this.config.measure.y || this.measures[1];

        //Set baseline and comparison visits.
        this.config.visits.baseline =
            this.config.visits.baseline.length > 0 ? this.config.visits.baseline : [this.visits[0]];

        this.config.visits.comparison =
            this.config.visits.comparison.length > 0
                ? this.config.visits.comparison
                : [this.visits[this.visits.length - 1]];
    }

    function onInit() {
        // 1. Remove invalid data.
        cleanData.call(this);

        // 2. trim measures.
        trimMeasures.call(this);

        // 3a Check filters against data.
        checkFilters.call(this);

        // 3b Get list of measures.
        getMeasures.call(this);

        // 3c Get list of visits.
        getVisits.call(this);

        //4a. Initialize the delta-delta settings &  Update control inputs.
        initSettings.call(this);
        updateControlInputs.call(this);

        //initialize custom events
        initCustomEvents.call(this);
    }

    function initNotes() {
        //Add footnote element.
        this.wrap
            .insert('p', ':first-child')
            .attr('class', 'record-note')
            .style('text-align', 'center')
            .style('font-weight', 'bold')
            .text('Click a point to see details.');

        //Add header element in which to list visits at which measure is captured.
        this.wrap.append('p', 'svg').attr('class', 'possible-visits');

        //Add element for participant counts.
        this.controls.wrap
            .append('em')
            .classed('annote', true)
            .style('display', 'block');
    }

    function updateVisitControls() {
        var _this = this;

        var config = this.config;
        var baselineSelect = this.controls.wrap
            .selectAll('.control-group')
            .filter(function (f) {
                return f.option === 'visits.baseline';
            })
            .select('select');
        baselineSelect
            .selectAll('option')
            .filter(function (f) {
                return _this.config.visits.baseline.indexOf(f) > -1;
            })
            .attr('selected', 'selected');

        var comparisonSelect = this.controls.wrap
            .selectAll('.control-group')
            .filter(function (f) {
                return f.option === 'visits.comparison';
            })
            .select('select');
        comparisonSelect
            .selectAll('option')
            .filter(function (f) {
                return _this.config.visits.comparison.indexOf(f) > -1;
            })
            .attr('selected', 'selected');
    }

    function onLayout() {
        initNotes.call(this);
        updateVisitControls.call(this);
    }

    function addParticipantLevelMetadata(d, participant_obj) {
        var varList = [];
        if (this.config.filters) {
            var filterVars = this.config.filters.map(function (d) {
                return d.hasOwnProperty('value_col') ? d.value_col : d;
            });
            varList = d3.merge([varList, filterVars]);
        }
        if (this.config.group_cols) {
            var groupVars = this.config.group_cols.map(function (d) {
                return d.hasOwnProperty('value_col') ? d.value_col : d;
            });
            varList = d3.merge([varList, groupVars]);
        }
        if (this.config.details) {
            var detailVars = this.config.details.map(function (d) {
                return d.hasOwnProperty('value_col') ? d.value_col : d;
            });
            varList = d3.merge([varList, detailVars]);
        }

        varList.forEach(function (v) {
            participant_obj[v] = '' + d[0][v];
        });
    }

    function getMeasureDetails(pt_data) {
        var config = this.config;
        var measure_details = d3
            .nest()
            .key(function (d) {
                return d[config.measure_col];
            })
            .rollup(function (di) {
                var measure_obj = {};
                measure_obj.key = di[0][config.measure_col];
                measure_obj.spark = 'sparkline placeholder';
                measure_obj.toggle = '+';
                measure_obj.raw = di;
                measure_obj.axisFlag =
                    measure_obj.key == config.measure.x
                        ? 'X'
                        : measure_obj.key == config.measure.y
                            ? 'Y'
                            : '';
                measure_obj.raw.forEach(function (dii) {
                    dii.baseline = config.visits.baseline.indexOf(dii[config.visit_col]) > -1;
                    dii.comparison = config.visits.comparison.indexOf(dii[config.visit_col]) > -1;
                    dii.color = dii.baseline ? 'blue' : dii.comparison ? 'orange' : '#999';
                });

                ['baseline', 'comparison'].forEach(function (t) {
                    measure_obj[t + '_records'] = di.filter(function (f) {
                        return config.visits[t].indexOf(f[config.visit_col]) > -1;
                    });

                    measure_obj[t + '_value'] = d3.mean(measure_obj[t + '_records'], function (d) {
                        return d[config.value_col];
                    });
                });
                measure_obj['delta'] = measure_obj.comparison_value - measure_obj.baseline_value;
                return measure_obj;
            })
            .entries(pt_data);
        measure_details = measure_details
            .map(function (m) {
                return m.values;
            })
            .sort(function (a, b) {
                if (a.axisFlag == 'X') return -1;
                else if (b.axisFlag == 'X') return 1;
                else if (a.axisFlag == 'Y') return -1;
                else if (b.axisFlag == 'Y') return 1;
                else if (a.key < b.key) return -1;
                else if (b.key > a.key) return 1;
                else return 0;
            });
        return measure_details;
    }

    function flattenData(rawData) {
        var _this = this;

        var nested = d3
            .nest()
            .key(function (d) {
                return d[_this.config.id_col];
            })
            .rollup(function (d) {
                var obj = {};
                obj.key = d[0][_this.config.id_col];
                obj.raw = d;
                obj.measures = getMeasureDetails.call(_this, d);

                obj.x_details = obj.measures.find(function (f) {
                    return f.key == _this.config.measure.x;
                });
                obj.delta_x = obj.x_details ? obj.x_details.delta : null;
                obj.delta_x_rounded = obj.x_details ? d3.format('0.2f')(obj.delta_x) : '';

                obj.y_details = obj.measures.find(function (f) {
                    return f.key == _this.config.measure.y;
                });
                obj.delta_y = obj.y_details ? obj.y_details.delta : null;
                obj.delta_y_rounded = obj.y_details ? d3.format('0.2f')(obj.delta_y) : '';

                addParticipantLevelMetadata.call(_this, d, obj);

                return obj;
            })
            .entries(rawData);

        return nested.map(function (m) {
            return m.values;
        });
    }

    function updateAxisSettings() {
        var config = this.config;

        //set config properties here since they aren't available in onInit
        config.x.column = 'delta_x';
        config.y.column = 'delta_y';
        config.marks[0].per = ['key'];

        config.x.label = 'Change in ' + config.measure.x;
        config.y.label = 'Change in ' + config.measure.y;
    }

    function onPreprocess() {
        updateAxisSettings.call(this);
        this.raw_data = flattenData.call(this, this.initial_data);
    }

    function onDatatransform() { }

    /*------------------------------------------------------------------------------------------------\
      Annotate number of participants based on current filters, number of participants in all, and
      the corresponding percentage.

      Inputs:

        chart - a webcharts chart object
        id_unit - a text string to label the units in the annotation (default = 'participants')
        selector - css selector for the annotation
    \------------------------------------------------------------------------------------------------*/

    function updateParticipantCount(chart, selector, id_unit) {
        //count the number of unique ids in the data set
        var totalObs = d3
            .set(
                chart.initial_data.map(function (d) {
                    return d[chart.config.id_col];
                })
            )
            .values().length;

        //count the number of unique ids in the current chart and calculate the percentage
        var currentObs = chart.filtered_data.filter(function (f) {
            return (
                !isNaN(f.delta_x) && f.delta_x !== null && !isNaN(f.delta_y) && f.delta_y !== null
            );
        }).length; // TODO: remove these records as part of the data flow

        var percentage = d3.format('0.1%')(currentObs / totalObs);

        //clear the annotation
        var annotation = d3.select(selector);
        annotation.selectAll('*').remove();

        //update the annotation
        var units = id_unit ? ' ' + id_unit : ' participant(s)';
        annotation.text(currentObs + ' of ' + totalObs + units + ' shown (' + percentage + ')');
    }

    function reset() {
        this.svg.selectAll('g.boxplot').remove();
        this.svg
            .selectAll('g.point')
            .classed('selected', false)
            .select('circle')
            .style('fill', this.config.colors[0]);
        this.wrap
            .select('.record-note')
            .style('text-align', 'center')
            .text('Click a point to see details.');
        this.listing.draw([]);
        this.listing.wrap.style('display', 'none');
    }

    function onDraw() {
        //Annotate selected and total number of participants.
        updateParticipantCount(this, '.annote');

        //Reset things.
        reset.call(this);
    }

    function drawBoxPlot(
        svg,
        results,
        height,
        width,
        domain,
        boxPlotWidth,
        boxColor,
        boxInsideColor,
        fmt,
        horizontal
    ) {
        //set default orientation to "horizontal"
        var horizontal = horizontal == undefined ? true : horizontal;

        //make the results numeric and sort
        var results = results
            .map(function (d) {
                return +d;
            })
            .sort(d3.ascending);

        //set up scales
        var y = d3.scale.linear().range([height, 0]);

        var x = d3.scale.linear().range([0, width]);

        if (horizontal) {
            y.domain(domain);
        } else {
            x.domain(domain);
        }

        var probs = [0.05, 0.25, 0.5, 0.75, 0.95];
        for (var i = 0; i < probs.length; i++) {
            probs[i] = d3.quantile(results, probs[i]);
        }

        var boxplot = svg
            .append('g')
            .attr('class', 'boxplot')
            .datum({ values: results, probs: probs });

        //draw rectangle from q1 to q3
        var box_x = horizontal ? x(0.5 - boxPlotWidth / 2) : x(probs[1]);
        var box_width = horizontal
            ? x(0.5 + boxPlotWidth / 2) - x(0.5 - boxPlotWidth / 2)
            : x(probs[3]) - x(probs[1]);
        var box_y = horizontal ? y(probs[3]) : y(0.5 + boxPlotWidth / 2);
        var box_height = horizontal
            ? -y(probs[3]) + y(probs[1])
            : y(0.5 - boxPlotWidth / 2) - y(0.5 + boxPlotWidth / 2);

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
                .attr('x1', horizontal ? x(0.5 - boxPlotWidth / 2) : x(probs[iS[i]]))
                .attr('x2', horizontal ? x(0.5 + boxPlotWidth / 2) : x(probs[iS[i]]))
                .attr('y1', horizontal ? y(probs[iS[i]]) : y(0.5 - boxPlotWidth / 2))
                .attr('y2', horizontal ? y(probs[iS[i]]) : y(0.5 + boxPlotWidth / 2))
                .style('fill', iSColor[i])
                .style('stroke', iSColor[i]);
        }

        //draw lines from 5% to 25% and from 75% to 95%
        var iS = [[0, 1], [3, 4]];
        for (var i = 0; i < iS.length; i++) {
            boxplot
                .append('line')
                .attr('class', 'boxplot')
                .attr('x1', horizontal ? x(0.5) : x(probs[iS[i][0]]))
                .attr('x2', horizontal ? x(0.5) : x(probs[iS[i][1]]))
                .attr('y1', horizontal ? y(probs[iS[i][0]]) : y(0.5))
                .attr('y2', horizontal ? y(probs[iS[i][1]]) : y(0.5))
                .style('stroke', boxColor);
        }

        boxplot
            .append('circle')
            .attr('class', 'boxplot mean')
            .attr('cx', horizontal ? x(0.5) : x(d3.mean(results)))
            .attr('cy', horizontal ? y(d3.mean(results)) : y(0.5))
            .attr('r', horizontal ? x(boxPlotWidth / 3) : y(1 - boxPlotWidth / 3))
            .style('fill', boxInsideColor)
            .style('stroke', boxColor);

        boxplot
            .append('circle')
            .attr('class', 'boxplot mean')
            .attr('cx', horizontal ? x(0.5) : x(d3.mean(results)))
            .attr('cy', horizontal ? y(d3.mean(results)) : y(0.5))
            .attr('r', horizontal ? x(boxPlotWidth / 6) : y(1 - boxPlotWidth / 6))
            .style('fill', boxColor)
            .style('stroke', 'None');

        var formatx = fmt ? d3.format(fmt) : d3.format('.2f');

        boxplot
            .selectAll('.boxplot')
            .append('title')
            .text(function (d) {
                return (
                    'N = ' +
                    d.values.length +
                    '\n' +
                    'Min = ' +
                    d3.min(d.values) +
                    '\n' +
                    '5th % = ' +
                    formatx(d3.quantile(d.values, 0.05)) +
                    '\n' +
                    'Q1 = ' +
                    formatx(d3.quantile(d.values, 0.25)) +
                    '\n' +
                    'Median = ' +
                    formatx(d3.median(d.values)) +
                    '\n' +
                    'Q3 = ' +
                    formatx(d3.quantile(d.values, 0.75)) +
                    '\n' +
                    '95th % = ' +
                    formatx(d3.quantile(d.values, 0.95)) +
                    '\n' +
                    'Max = ' +
                    d3.max(d.values) +
                    '\n' +
                    'Mean = ' +
                    formatx(d3.mean(d.values)) +
                    '\n' +
                    'StDev = ' +
                    formatx(d3.deviation(d.values))
                );
            });
    }

    function addBoxPlots() {
        // Y-axis box plot
        var yValues = this.current_data.map(function (d) {
            return d.values.y;
        });
        var ybox = this.svg.append('g').attr('class', 'yMargin');
        drawBoxPlot(ybox, yValues, this.plot_height, 1, this.y_dom, 10, '#bbb', 'white');
        ybox.select('g.boxplot').attr(
            'transform',
            'translate(' + (this.plot_width + this.config.margin.right / 2) + ',0)'
        );

        //X-axis box plot
        var xValues = this.current_data.map(function (d) {
            return d.values.x;
        });
        var xbox = this.svg.append('g').attr('class', 'xMargin');
        drawBoxPlot(
            xbox, //svg element
            xValues, //values
            1, //height
            this.plot_width, //width
            this.x_dom, //domain
            10, //box plot width
            '#bbb', //box color
            'white', //detail color
            '0.2f', //format
            false // horizontal?
        );
        xbox.select('g.boxplot').attr(
            'transform',
            'translate(0,' + -(this.config.margin.top / 2) + ')'
        );
    }

    function updateClipPath() {
        //embiggen clip-path so points aren't clipped
        var radius = this.config.marks.find(function (mark) {
            return mark.type === 'circle';
        }).radius;
        this.svg
            .select('.plotting-area')
            .attr('width', this.plot_width + radius * 2 + 2) // plot width + circle radius * 2 + circle stroke width * 2
            .attr('height', this.plot_height + radius * 2 + 2) // plot height + circle radius * 2 + circle stroke width * 2
            .attr(
                'transform',
                'translate(-' +
                (radius + 1) + // translate left circle radius + circle stroke width
                ',-' +
                (radius + 1) + // translate up circle radius + circle stroke width
                ')'
            );
    }

    function addSparkLines(d) {
        var chart = this.chart;
        var config = this.chart.config;

        if (this.data.raw.length > 0) {
            //don't try to draw sparklines if the table is empty
            this.tbody
                .selectAll('tr')
                .style('background', 'none')
                .style('border-bottom', '.5px solid black')
                .each(function (row_d) {
                    //Spark line cell
                    var cell = d3
                        .select(this)
                        .select('td.spark')
                        .classed('minimized', true)
                        .text(''),
                        toggle = d3
                            .select(this)
                            .select('td.toggle')
                            .html('&#x25BD;')
                            .style('cursor', 'pointer')
                            .style('color', '#999')
                            .style('vertical-align', 'middle'),
                        width = 100,
                        height = 25,
                        offset = 4,
                        overTime = row_d.raw.sort(function (a, b) {
                            return +a[config.visitn_col] - +b[config.visitn_col];
                        });

                    var x = d3.scale
                        .linear()
                        .domain(
                            d3.extent(overTime, function (m) {
                                return +m[config.visitn_col];
                            })
                        )
                        .range([offset, width - offset]);

                    //y-domain includes 99th population percentile + any participant outliers
                    var y = d3.scale
                        .linear()
                        .domain(
                            d3.extent(overTime, function (m) {
                                return +m[config.value_col];
                            })
                        )
                        .range([height - offset, offset]);

                    //render the svg
                    var canvas = cell
                        .append('svg')
                        .attr({
                            width: width,
                            height: height
                        })
                        .append('g');

                    //draw the sparkline
                    var draw_sparkline = d3.svg
                        .line()
                        .interpolate('linear')
                        .x(function (d) {
                            return x(d[config.visitn_col]);
                        })
                        .y(function (d) {
                            return y(d[config.value_col]);
                        });
                    var sparkline = canvas
                        .append('path')
                        .datum(overTime)
                        .attr({
                            class: 'sparkLine',
                            d: draw_sparkline,
                            fill: 'none',
                            stroke: '#999'
                        });

                    //draw baseline values

                    var circles = canvas
                        .selectAll('circle')
                        .data(overTime)
                        .enter()
                        .append('circle')
                        .attr('class', 'circle outlier')
                        .attr('cx', function (d) {
                            return x(d[config.visitn_col]);
                        })
                        .attr('cy', function (d) {
                            return y(d[config.value_col]);
                        })
                        .attr('r', '2px')
                        .attr('stroke', function (d) {
                            return d.color;
                        })
                        .attr('fill', function (d) {
                            return d.color == '#999' ? 'transparent' : d.color;
                        })
                        .append('title')
                        .text(function (d) {
                            return (
                                'Value = ' +
                                d[config.value_col] +
                                ' @ Visit ' +
                                d[config.visitn_col]
                            );
                        });
                });
        }
    }

    function addFootnote() {
        this.wrap.select('span.footnote').remove();
        this.wrap
            .append('span')
            .attr('class', 'footnote')
            .style('font-size', '0.7em')
            .style('color', '#999')
            .text(
                'This table shows all lab values collected for the selected participant. Filled blue and orange circles indicate baseline and comparison visits respectively - all other visits are draw for reference using with empty gray circles. Change over time values greater than 0 are shown in green; values less than 0 shown in red.'
            );
    }

    function formatDelta() {
        this.tbody
            .selectAll('tr')
            .select('td.delta')
            .text(function (d) {
                return isNaN(d.delta) ? 'NA' : d3.format('+0.2f')(d.delta);
            })
            .style('color', function (d) {
                return isNaN(d.delta)
                    ? '#ccc'
                    : d.delta > 0
                        ? 'green'
                        : d.delta < 0
                            ? 'red'
                            : '#999';
            });
    }

    function addAxisFlag() {
        var table = this;
        ['X', 'Y'].forEach(function (axis) {
            var cell = table.tbody
                .selectAll('tr')
                .filter(function (d) {
                    return d.axisFlag == axis;
                })
                .select('td.key')
                .text('');

            cell.append('span')
                .attr('class', 'sdd-axisLabel')
                .text(axis + '-axis');

            cell.append('span').text(function (d) {
                return d.key;
            });
        });
    }

    function showParticipantDetails(d) {
        var table = this;
        var chart = this.chart;
        var raw = d.raw[0];

        //show detail variables in a ul
        table.wrap.select('ul.pdd-pt-details').remove();
        var ul = table.wrap
            .insert('ul', '*')
            .attr('class', 'pdd-pt-details')
            .style('list-style', 'none')
            .style('padding', '0');

        var lis = ul
            .selectAll('li')
            .data(chart.config.details)
            .enter()
            .append('li')
            .style('', 'block')
            .style('display', 'inline-block')
            .style('text-align', 'center')
            .style('padding', '0.5em');

        lis.append('div')
            .text(function (d) {
                return d.label;
            })
            .attr('div', 'label')
            .style('font-size', '0.8em');

        lis.append('div')
            .text(function (d) {
                return raw[d.value_col];
            })
            .attr('div', 'value');
    }

    function drawMeasureTable(d) {
        var chart = this;
        var config = this.config;

        var point_data = d.values.raw[0];
        chart.listing.wrap.style('display', null);

        chart.listing.on('draw', function () {
            showParticipantDetails.call(this, point_data);
            addSparkLines.call(this);
            formatDelta.call(this);
            addAxisFlag.call(this);
            addFootnote.call(this);

            this.thead.style('border-top', '2px solid black');
        });
        chart.listing.draw(point_data.measures);
    }

    function addPointClick() {
        var chart = this;
        var config = this.config;
        var points = this.marks[0].circles;

        points.on('click', function (d) {
            points
                .attr('stroke', function (d) {
                    return chart.colorScale(d.values.raw[0][config.color_by]);
                })
                .attr('stroke-width', 0.5);

            d3.select(this)
                .attr('stroke-width', 3)
                .attr('stroke', 'black');
            drawMeasureTable.call(chart, d);
        });
    }

    var commonjsGlobal =
        typeof globalThis !== 'undefined'
            ? globalThis
            : typeof window !== 'undefined'
                ? window
                : typeof global !== 'undefined'
                    ? global
                    : typeof self !== 'undefined'
                        ? self
                        : {};

    function createCommonjsModule(fn, module) {
        return (module = { exports: {} }), fn(module, module.exports), module.exports;
    }

    var regression = createCommonjsModule(function (module, exports) {
        (function (global, factory) {
            {
                factory(module);
            }
        })(commonjsGlobal, function (module) {
            function _defineProperty(obj, key, value) {
                if (key in obj) {
                    Object.defineProperty(obj, key, {
                        value: value,
                        enumerable: true,
                        configurable: true,
                        writable: true
                    });
                } else {
                    obj[key] = value;
                }

                return obj;
            }

            var _extends =
                Object.assign ||
                function (target) {
                    for (var i = 1; i < arguments.length; i++) {
                        var source = arguments[i];

                        for (var key in source) {
                            if (Object.prototype.hasOwnProperty.call(source, key)) {
                                target[key] = source[key];
                            }
                        }
                    }

                    return target;
                };

            function _toConsumableArray(arr) {
                if (Array.isArray(arr)) {
                    for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) {
                        arr2[i] = arr[i];
                    }

                    return arr2;
                } else {
                    return Array.from(arr);
                }
            }

            var DEFAULT_OPTIONS = { order: 2, precision: 2, period: null };

            /**
             * Determine the coefficient of determination (r^2) of a fit from the observations
             * and predictions.
             *
             * @param {Array<Array<number>>} data - Pairs of observed x-y values
             * @param {Array<Array<number>>} results - Pairs of observed predicted x-y values
             *
             * @return {number} - The r^2 value, or NaN if one cannot be calculated.
             */
            function determinationCoefficient(data, results) {
                var predictions = [];
                var observations = [];

                data.forEach(function (d, i) {
                    if (d[1] !== null) {
                        observations.push(d);
                        predictions.push(results[i]);
                    }
                });

                var sum = observations.reduce(function (a, observation) {
                    return a + observation[1];
                }, 0);
                var mean = sum / observations.length;

                var ssyy = observations.reduce(function (a, observation) {
                    var difference = observation[1] - mean;
                    return a + difference * difference;
                }, 0);

                var sse = observations.reduce(function (accum, observation, index) {
                    var prediction = predictions[index];
                    var residual = observation[1] - prediction[1];
                    return accum + residual * residual;
                }, 0);

                return 1 - sse / ssyy;
            }

            /**
             * Determine the solution of a system of linear equations A * x = b using
             * Gaussian elimination.
             *
             * @param {Array<Array<number>>} input - A 2-d matrix of data in row-major form [ A | b ]
             * @param {number} order - How many degrees to solve for
             *
             * @return {Array<number>} - Vector of normalized solution coefficients matrix (x)
             */
            function gaussianElimination(input, order) {
                var matrix = input;
                var n = input.length - 1;
                var coefficients = [order];

                for (var i = 0; i < n; i++) {
                    var maxrow = i;
                    for (var j = i + 1; j < n; j++) {
                        if (Math.abs(matrix[i][j]) > Math.abs(matrix[i][maxrow])) {
                            maxrow = j;
                        }
                    }

                    for (var k = i; k < n + 1; k++) {
                        var tmp = matrix[k][i];
                        matrix[k][i] = matrix[k][maxrow];
                        matrix[k][maxrow] = tmp;
                    }

                    for (var _j = i + 1; _j < n; _j++) {
                        for (var _k = n; _k >= i; _k--) {
                            matrix[_k][_j] -= (matrix[_k][i] * matrix[i][_j]) / matrix[i][i];
                        }
                    }
                }

                for (var _j2 = n - 1; _j2 >= 0; _j2--) {
                    var total = 0;
                    for (var _k2 = _j2 + 1; _k2 < n; _k2++) {
                        total += matrix[_k2][_j2] * coefficients[_k2];
                    }

                    coefficients[_j2] = (matrix[n][_j2] - total) / matrix[_j2][_j2];
                }

                return coefficients;
            }

            /**
             * Round a number to a precision, specificed in number of decimal places
             *
             * @param {number} number - The number to round
             * @param {number} precision - The number of decimal places to round to:
             *                             > 0 means decimals, < 0 means powers of 10
             *
             *
             * @return {numbr} - The number, rounded
             */
            function round(number, precision) {
                var factor = Math.pow(10, precision);
                return Math.round(number * factor) / factor;
            }

            /**
             * The set of all fitting methods
             *
             * @namespace
             */
            var methods = {
                linear: function linear(data, options) {
                    var sum = [0, 0, 0, 0, 0];
                    var len = 0;

                    for (var n = 0; n < data.length; n++) {
                        if (data[n][1] !== null) {
                            len++;
                            sum[0] += data[n][0];
                            sum[1] += data[n][1];
                            sum[2] += data[n][0] * data[n][0];
                            sum[3] += data[n][0] * data[n][1];
                            sum[4] += data[n][1] * data[n][1];
                        }
                    }

                    var run = len * sum[2] - sum[0] * sum[0];
                    var rise = len * sum[3] - sum[0] * sum[1];
                    var gradient = run === 0 ? 0 : round(rise / run, options.precision);
                    var intercept = round(
                        sum[1] / len - (gradient * sum[0]) / len,
                        options.precision
                    );

                    var predict = function predict(x) {
                        return [
                            round(x, options.precision),
                            round(gradient * x + intercept, options.precision)
                        ];
                    };

                    var points = data.map(function (point) {
                        return predict(point[0]);
                    });

                    return {
                        points: points,
                        predict: predict,
                        equation: [gradient, intercept],
                        r2: round(determinationCoefficient(data, points), options.precision),
                        string:
                            intercept === 0
                                ? 'y = ' + gradient + 'x'
                                : 'y = ' + gradient + 'x + ' + intercept
                    };
                },
                exponential: function exponential(data, options) {
                    var sum = [0, 0, 0, 0, 0, 0];

                    for (var n = 0; n < data.length; n++) {
                        if (data[n][1] !== null) {
                            sum[0] += data[n][0];
                            sum[1] += data[n][1];
                            sum[2] += data[n][0] * data[n][0] * data[n][1];
                            sum[3] += data[n][1] * Math.log(data[n][1]);
                            sum[4] += data[n][0] * data[n][1] * Math.log(data[n][1]);
                            sum[5] += data[n][0] * data[n][1];
                        }
                    }

                    var denominator = sum[1] * sum[2] - sum[5] * sum[5];
                    var a = Math.exp((sum[2] * sum[3] - sum[5] * sum[4]) / denominator);
                    var b = (sum[1] * sum[4] - sum[5] * sum[3]) / denominator;
                    var coeffA = round(a, options.precision);
                    var coeffB = round(b, options.precision);
                    var predict = function predict(x) {
                        return [
                            round(x, options.precision),
                            round(coeffA * Math.exp(coeffB * x), options.precision)
                        ];
                    };

                    var points = data.map(function (point) {
                        return predict(point[0]);
                    });

                    return {
                        points: points,
                        predict: predict,
                        equation: [coeffA, coeffB],
                        string: 'y = ' + coeffA + 'e^(' + coeffB + 'x)',
                        r2: round(determinationCoefficient(data, points), options.precision)
                    };
                },
                logarithmic: function logarithmic(data, options) {
                    var sum = [0, 0, 0, 0];
                    var len = data.length;

                    for (var n = 0; n < len; n++) {
                        if (data[n][1] !== null) {
                            sum[0] += Math.log(data[n][0]);
                            sum[1] += data[n][1] * Math.log(data[n][0]);
                            sum[2] += data[n][1];
                            sum[3] += Math.pow(Math.log(data[n][0]), 2);
                        }
                    }

                    var a = (len * sum[1] - sum[2] * sum[0]) / (len * sum[3] - sum[0] * sum[0]);
                    var coeffB = round(a, options.precision);
                    var coeffA = round((sum[2] - coeffB * sum[0]) / len, options.precision);

                    var predict = function predict(x) {
                        return [
                            round(x, options.precision),
                            round(
                                round(coeffA + coeffB * Math.log(x), options.precision),
                                options.precision
                            )
                        ];
                    };

                    var points = data.map(function (point) {
                        return predict(point[0]);
                    });

                    return {
                        points: points,
                        predict: predict,
                        equation: [coeffA, coeffB],
                        string: 'y = ' + coeffA + ' + ' + coeffB + ' ln(x)',
                        r2: round(determinationCoefficient(data, points), options.precision)
                    };
                },
                power: function power(data, options) {
                    var sum = [0, 0, 0, 0, 0];
                    var len = data.length;

                    for (var n = 0; n < len; n++) {
                        if (data[n][1] !== null) {
                            sum[0] += Math.log(data[n][0]);
                            sum[1] += Math.log(data[n][1]) * Math.log(data[n][0]);
                            sum[2] += Math.log(data[n][1]);
                            sum[3] += Math.pow(Math.log(data[n][0]), 2);
                        }
                    }

                    var b = (len * sum[1] - sum[0] * sum[2]) / (len * sum[3] - Math.pow(sum[0], 2));
                    var a = (sum[2] - b * sum[0]) / len;
                    var coeffA = round(Math.exp(a), options.precision);
                    var coeffB = round(b, options.precision);

                    var predict = function predict(x) {
                        return [
                            round(x, options.precision),
                            round(
                                round(coeffA * Math.pow(x, coeffB), options.precision),
                                options.precision
                            )
                        ];
                    };

                    var points = data.map(function (point) {
                        return predict(point[0]);
                    });

                    return {
                        points: points,
                        predict: predict,
                        equation: [coeffA, coeffB],
                        string: 'y = ' + coeffA + 'x^' + coeffB,
                        r2: round(determinationCoefficient(data, points), options.precision)
                    };
                },
                polynomial: function polynomial(data, options) {
                    var lhs = [];
                    var rhs = [];
                    var a = 0;
                    var b = 0;
                    var len = data.length;
                    var k = options.order + 1;

                    for (var i = 0; i < k; i++) {
                        for (var l = 0; l < len; l++) {
                            if (data[l][1] !== null) {
                                a += Math.pow(data[l][0], i) * data[l][1];
                            }
                        }

                        lhs.push(a);
                        a = 0;

                        var c = [];
                        for (var j = 0; j < k; j++) {
                            for (var _l = 0; _l < len; _l++) {
                                if (data[_l][1] !== null) {
                                    b += Math.pow(data[_l][0], i + j);
                                }
                            }
                            c.push(b);
                            b = 0;
                        }
                        rhs.push(c);
                    }
                    rhs.push(lhs);

                    var coefficients = gaussianElimination(rhs, k).map(function (v) {
                        return round(v, options.precision);
                    });

                    var predict = function predict(x) {
                        return [
                            round(x, options.precision),
                            round(
                                coefficients.reduce(function (sum, coeff, power) {
                                    return sum + coeff * Math.pow(x, power);
                                }, 0),
                                options.precision
                            )
                        ];
                    };

                    var points = data.map(function (point) {
                        return predict(point[0]);
                    });

                    var string = 'y = ';
                    for (var _i = coefficients.length - 1; _i >= 0; _i--) {
                        if (_i > 1) {
                            string += coefficients[_i] + 'x^' + _i + ' + ';
                        } else if (_i === 1) {
                            string += coefficients[_i] + 'x + ';
                        } else {
                            string += coefficients[_i];
                        }
                    }

                    return {
                        string: string,
                        points: points,
                        predict: predict,
                        equation: [].concat(_toConsumableArray(coefficients)).reverse(),
                        r2: round(determinationCoefficient(data, points), options.precision)
                    };
                }
            };

            function createWrapper() {
                var reduce = function reduce(accumulator, name) {
                    return _extends(
                        {
                            _round: round
                        },
                        accumulator,
                        _defineProperty({}, name, function (data, supplied) {
                            return methods[name](data, _extends({}, DEFAULT_OPTIONS, supplied));
                        })
                    );
                };

                return Object.keys(methods).reduce(reduce, {});
            }

            module.exports = createWrapper();
        });
    });

    function addRegressionLine() {
        if (this.config.add_regression_line) {
            var chart = this;
            var config = this.config;

            // map chart data to array and calculate regression using regression-js
            var arrayData = chart.filtered_data
                .filter(function (f) {
                    return !isNaN(f.delta_x);
                })
                .filter(function (f) {
                    return !isNaN(f.delta_y);
                })
                .map(function (d) {
                    return [+d.delta_x, +d.delta_y];
                });

            var result = regression.linear(arrayData);

            //calculate predicted values for min and max points on the chart
            var min_x = chart.x_dom[0];
            var min_xy = result.predict(min_x);
            var max_x = chart.x_dom[1];
            var max_xy = result.predict(max_x);

            //draw the regression line
            var line = d3.svg
                .line()
                .x(function (d) {
                    return chart.x(d[0]);
                })
                .y(function (d) {
                    return chart.y(d[1]);
                });
            chart.svg.selectAll('.regressionLine').remove();
            chart.svg
                .append('path')
                .classed('regressionLine', true)
                .datum([min_xy, max_xy])
                .attr('d', line)
                .attr('stroke', 'black')
                .attr('stroke-dasharray', '3,5');

            //add footnote with R2 and exact calculation
            chart.wrap.select('span.regression-note').remove();
            chart.wrap
                .append('span')
                .classed('regression-note', true)
                .html(
                    'The dashed line shows the result of a simple linear regression. Additional details are shown below. <br> Equation: ' +
                    result.string +
                    '<br> R<sup>2</sup>: ' +
                    d3.format('0.2f')(result.r2)
                );
        }
    }

    function onResize() {
        addBoxPlots.call(this);
        updateClipPath.call(this);
        addPointClick.call(this);
        addRegressionLine.call(this);
    }

    function onDestroy() { }

    var callbacks = {
        onInit: onInit,
        onLayout: onLayout,
        onPreprocess: onPreprocess,
        onDatatransform: onDatatransform,
        onDraw: onDraw,
        onResize: onResize,
        onDestroy: onDestroy
    };

    function layout(element) {
        var container = d3.select(element);
        container
            .append('div')
            .classed('sdd-component', true)
            .attr('id', 'sdd-controls');
        container
            .append('div')
            .classed('sdd-component', true)
            .attr('id', 'sdd-chart');
        container
            .append('div')
            .classed('sdd-component', true)
            .attr('id', 'sdd-listing');
    }

    function styles() {
        var styles = [
            '#safety-delta-delta {' + '    width: 100%;' + '    display: inline-block;' + '}',
            '.sdd-component {' +
            '    margin: 0;' +
            '    border: none;' +
            '    padding: 0;' +
            '    display: inline-block;' +
            '}',

            //controls
            '#sdd-controls {' + '    width: 25%;' + '    float: left;' + '}',
            '#sdd-controls .control-group {' +
            '    width: 98%;' +
            '    margin: 0 2% 5px 0;' +
            '    padding: 0;' +
            '}',
            '#sdd-controls .control-group > * {' + '    display: inline-block;' + '}',
            '#sdd-controls .changer {' + '    float: right;' + '    width: 50%;' + '}',
            '#sdd-controls .wc-control-label {' +
            '    text-align: right;' +
            '    width: 48%;' +
            '}',
            '#sdd-controls .annote {' + '    width: 98%;' + '    text-align: right;' + '}',

            //chart
            '#sdd-chart {' + '    width: 36%;' + '    margin: 0 2%;' + '}',
            '.wc-data-mark {' + '    cursor: pointer;' + '}',
            '.wc-data-mark:hover {' + '    stroke: black;' + '    stroke-width: 3;' + '}',
            '.regression-note {' +
            //'    font-size: 0.8em;' +
            '    color: #999;' +
            '}',

            //listing
            '#sdd-listing {' + '    width: 35%;' + '    float: right;' + '}',
            '#sdd-listing .wc-table table {' + '    width: 100%;' + '    display: table;' + '}',
            '#sdd-listing .wc-table th:not(:first-child),' +
            '#sdd-listing .wc-table td:not(:first-child) {' +
            '    text-align: right;' +
            '}',
            '.sdd-axisLabel{' +
            'font-size:75%;' +
            'border-radius:0.25em;' +
            'padding:.2em .6em .3em;' +
            'margin-right:0.4em;' +
            'background-color:#5bc0de;' +
            'color:white;' +
            'font-weight:700;' +
            '}'
        ];
        var style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = styles.join('\n');
        document.getElementsByTagName('head')[0].appendChild(style);
    }

    function safetyDeltaDelta() {
        var element = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'body';
        var settings = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

        //layout and styles
        layout(element);
        styles();

        //Define chart.
        var mergedSettings = Object.assign(
            {},
            JSON.parse(JSON.stringify(configuration.settings)),
            settings
        );
        var syncedSettings = configuration.syncSettings(mergedSettings);
        var syncedControlInputs = configuration.syncControlInputs(
            configuration.controlInputs(),
            syncedSettings
        );
        var controls = webcharts.createControls(
            document.querySelector(element).querySelector('#sdd-controls'),
            {
                location: 'top',
                inputs: syncedControlInputs
            }
        );
        var chart = webcharts.createChart(
            document.querySelector(element).querySelector('#sdd-chart'),
            syncedSettings,
            controls
        );

        //Define chart callbacks.
        for (var callback in callbacks) {
            chart.on(callback.substring(2).toLowerCase(), callbacks[callback]);
        } //listing
        var listing = webcharts.createTable(
            document.querySelector(element).querySelector('#sdd-listing'),
            configuration.listingSettings()
        );
        listing.wrap.style('display', 'none'); // empty table's popping up briefly
        listing.init([]);
        chart.listing = listing;
        listing.chart = chart;

        return chart;
    }

    return safetyDeltaDelta;
});