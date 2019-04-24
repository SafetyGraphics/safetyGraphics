(function(global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined'
        ? (module.exports = factory(require('d3'), require('webcharts')))
        : typeof define === 'function' && define.amd
            ? define(['d3', 'webcharts'], factory)
            : (global.safetyHistogram = factory(global.d3, global.webCharts));
})(this, function(d3, webcharts) {
    'use strict';

    if (typeof Object.assign != 'function') {
        // Must be writable: true, enumerable: false, configurable: true
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
        function(x) {
            return Math.log(x) * Math.LOG10E;
        };

    var rendererSpecificSettings = {
        //required variables
        id_col: 'USUBJID',
        measure_col: 'TEST',
        unit_col: 'STRESU',
        value_col: 'STRESN',
        normal_col_low: 'STNRLO',
        normal_col_high: 'STNRHI',

        //optional variables
        filters: null,
        details: null,

        //miscellaneous settings
        start_value: null,
        normal_range: true,
        displayNormalRange: false
    };

    var webchartsSettings = {
        x: {
            type: 'linear',
            column: null, // set in syncSettings()
            label: null, // set in syncSettings()
            domain: [null, null], // set in preprocess callback
            format: null, // set in preprocess callback
            bin: 25
        },
        y: {
            type: 'linear',
            column: null,
            label: '# of Observations',
            domain: [0, null],
            format: '1d',
            behavior: 'flex'
        },
        marks: [
            {
                per: [], // set in syncSettings()
                type: 'bar',
                summarizeY: 'count',
                summarizeX: 'mean',
                attributes: { 'fill-opacity': 0.75 }
            }
        ],
        aspect: 3
    };

    var defaultSettings = Object.assign({}, rendererSpecificSettings, webchartsSettings);

    //Replicate settings in multiple places in the settings object
    function syncSettings(settings) {
        settings.x.label = settings.start_value;
        settings.x.column = settings.value_col;
        settings.marks[0].per[0] = settings.value_col;

        if (!settings.normal_range) {
            settings.normal_col_low = null;
            settings.normal_col_high = null;
        }

        //Define default details.
        var defaultDetails = [{ value_col: settings.id_col, label: 'Subject Identifier' }];

        if (!(settings.filters instanceof Array)) {
            settings.filters = typeof settings.filters == 'string' ? [settings.filters] : [];
        }

        if (settings.filters)
            settings.filters.forEach(function(filter) {
                return defaultDetails.push({
                    value_col: filter.value_col ? filter.value_col : filter,
                    label: filter.label
                        ? filter.label
                        : filter.value_col
                            ? filter.value_col
                            : filter
                });
            });
        defaultDetails.push({ value_col: settings.value_col, label: 'Result' });
        if (settings.normal_col_low)
            defaultDetails.push({
                value_col: settings.normal_col_low,
                label: 'Lower Limit of Normal'
            });
        if (settings.normal_col_high)
            defaultDetails.push({
                value_col: settings.normal_col_high,
                label: 'Upper Limit of Normal'
            });

        //If [settings.details] is not an array:
        if (!(settings.details instanceof Array)) {
            settings.details = typeof settings.details == 'string' ? [settings.details] : [];
        }

        //If [settings.details] is not specified:
        if (!settings.details) settings.details = defaultDetails;
        else {
            //If [settings.details] is specified:
            //Allow user to specify an array of columns or an array of objects with a column property
            //and optionally a column label.
            settings.details.forEach(function(detail) {
                if (
                    defaultDetails
                        .map(function(d) {
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

    //Map values from settings to control inputs
    function syncControlInputs(settings) {
        var defaultControls = [
            {
                type: 'subsetter',
                label: 'Measure',
                value_col: settings.measure_col,
                start: settings.start_value
            },
            {
                type: 'checkbox',
                label: 'Normal Range',
                option: 'displayNormalRange'
            },
            {
                type: 'number',
                label: 'Lower Limit',
                option: 'x.domain[0]',
                require: true
            },
            {
                type: 'number',
                label: 'Upper Limit',
                option: 'x.domain[1]',
                require: true
            }
        ];

        if (Array.isArray(settings.filters) && settings.filters.length > 0) {
            var otherFilters = settings.filters.map(function(filter) {
                var filterObject = {
                    type: 'subsetter',
                    value_col: filter.value_col || filter,
                    label: filter.label || filter.value_col || filter
                };
                return filterObject;
            });

            return defaultControls.concat(otherFilters);
        } else return defaultControls;
    }

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
        var preclean = this.raw_data;
        var clean = this.raw_data.filter(function(d) {
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
        this.raw_data = clean;

        //Attach array of continuous measures to chart object.
        this.measures = d3
            .set(
                this.raw_data.map(function(d) {
                    return d[_this.config.measure_col];
                })
            )
            .values()
            .sort();
    }

    function addVariables() {
        var _this = this;

        this.raw_data.forEach(function(d) {
            d[_this.config.measure_col] = d[_this.config.measure_col].trim();
        });
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

    function setInitialMeasure() {
        this.controls.config.inputs.find(function(input) {
            return input.label === 'Measure';
        }).start =
            this.config.start_value && this.measures.indexOf(this.config.start_value) > -1
                ? this.config.start_value
                : this.measures[0];
    }

    function onInit() {
        // 1. Count total participants prior to data cleaning.
        countParticipants.call(this);

        // 2. Drop missing values and remove measures with any non-numeric results.
        cleanData.call(this);

        // 3a Define additional variables.
        addVariables.call(this);

        // 3b Remove filters for nonexistent or single-level variables.
        checkFilters.call(this);

        // 3c Choose the start value for the Test filter
        setInitialMeasure.call(this);
    }

    function addXdomainResetButton() {
        var _this = this;

        //Add x-domain reset button container.
        var resetContainer = this.controls.wrap
            .insert('div', '.control-group:nth-child(3)')
            .classed('control-group x-axis', true)
            .datum({
                type: 'button',
                option: 'x.domain',
                label: 'x-axis:'
            });

        //Add label.
        resetContainer
            .append('span')
            .attr('class', 'wc-control-label')
            .style('text-align', 'right')
            .text('X-axis:');

        //Add button.
        resetContainer
            .append('button')
            .text('Reset Limits')
            .on('click', function() {
                _this.config.x.domain = _this.measure_domain;

                _this.controls.wrap
                    .selectAll('.control-group')
                    .filter(function(f) {
                        return f.option === 'x.domain[0]';
                    })
                    .select('input')
                    .property('value', _this.config.x.domain[0]);

                _this.controls.wrap
                    .selectAll('.control-group')
                    .filter(function(f) {
                        return f.option === 'x.domain[1]';
                    })
                    .select('input')
                    .property('value', _this.config.x.domain[1]);

                _this.draw();
            });
    }

    function classXaxisLimitControls() {
        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(d) {
                return ['Lower Limit', 'Upper Limit'].indexOf(d.label) > -1;
            })
            .classed('x-axis', true);
    }

    function addPopulationCountContainer() {
        this.controls.wrap
            .append('div')
            .attr('id', 'populationCount')
            .style('font-style', 'italic');
    }

    function addFootnoteContainer() {
        this.wrap
            .insert('p', '.wc-chart')
            .attr('class', 'annote')
            .text('Click a bar for details.');
    }

    function onLayout() {
        //Add button that resets x-domain.
        addXdomainResetButton.call(this);

        //Add x-axis class to x-axis limit controls.
        classXaxisLimitControls.call(this);

        //Add container for population count.
        addPopulationCountContainer.call(this);

        //Add container for footnote.
        addFootnoteContainer.call(this);
    }

    function getCurrentMeasure() {
        var _this = this;

        this.previousMeasure = this.currentMeasure;
        this.currentMeasure = this.filters.find(function(filter) {
            return filter.col === _this.config.measure_col;
        }).val;
    }

    function defineMeasureData() {
        var _this = this;

        this.measure_data = this.raw_data.filter(function(d) {
            return d[_this.config.measure_col] === _this.currentMeasure;
        });
        this.measure_domain = d3.extent(this.measure_data, function(d) {
            return +d[_this.config.value_col];
        });
    }

    function setXdomain() {
        if (this.currentMeasure !== this.previousMeasure)
            // new measure
            this.config.x.domain = this.measure_domain;
        else if (this.config.x.domain[0] > this.config.x.domain[1])
            // invalid domain
            this.config.x.domain.reverse();
        else if (this.config.x.domain[0] === this.config.x.domain[1])
            // domain with zero range
            this.config.x.domain = this.config.x.domain.map(function(d, i) {
                return i === 0 ? d - d * 0.01 : d + d * 0.01;
            });
    }

    function setXaxisLabel() {
        this.config.x.label =
            this.currentMeasure +
            (this.config.unit_col && this.measure_data[0][this.config.unit_col]
                ? ' (' + this.measure_data[0][this.config.unit_col] + ')'
                : '');
    }

    function setXprecision() {
        var _this = this;

        //Calculate range of current measure and the log10 of the range to choose an appropriate precision.
        this.config.x.range = this.config.x.domain[1] - this.config.x.domain[0];
        this.config.x.log10range = Math.log10(this.config.x.range);
        this.config.x.roundedLog10range = Math.round(this.config.x.log10range);
        this.config.x.precision1 = -1 * (this.config.x.roundedLog10range - 1);
        this.config.x.precision2 = -1 * (this.config.x.roundedLog10range - 2);

        //Define the format of the x-axis tick labels and x-domain controls.
        this.config.x.format =
            this.config.x.log10range > 0.5 ? '1f' : '.' + this.config.x.precision1 + 'f';
        this.config.x.d3_format = d3.format(this.config.x.format);
        this.config.x.formatted_domain = this.config.x.domain.map(function(d) {
            return _this.config.x.d3_format(d);
        });

        //Define the bin format: one less than the x-axis format.
        this.config.x.format1 =
            this.config.x.log10range > 5 ? '1f' : '.' + this.config.x.precision2 + 'f';
        this.config.x.d3_format1 = d3.format(this.config.x.format1);
    }

    function updateXaxisLimitControls() {
        //Update x-axis limit controls.
        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(f) {
                return f.option === 'x.domain[0]';
            })
            .select('input')
            .property('value', this.config.x.formatted_domain[0]);
        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(f) {
                return f.option === 'x.domain[1]';
            })
            .select('input')
            .property('value', this.config.x.formatted_domain[1]);
    }

    function updateXaxisResetButton() {
        //Update tooltip of x-axis domain reset button.
        if (this.currentMeasure !== this.previousMeasure)
            this.controls.wrap
                .selectAll('.x-axis')
                .property(
                    'title',
                    'Initial Limits: [' +
                        this.config.x.domain[0] +
                        ' - ' +
                        this.config.x.domain[1] +
                        ']'
                );
    }

    function onPreprocess() {
        // 1. Capture currently selected measure.
        getCurrentMeasure.call(this);

        // 2. Filter data on currently selected measure.
        defineMeasureData.call(this);

        // 3a Set x-domain given currently selected measure.
        setXdomain.call(this);

        // 3b Set x-axis label to current measure.
        setXaxisLabel.call(this);

        // 4a Define precision of measure.
        setXprecision.call(this);

        // 4b Update x-axis reset button when measure changes.
        updateXaxisResetButton.call(this);

        // 4c Update x-axis limit controls to match y-axis domain.
        updateXaxisLimitControls.call(this);
    }

    function onDatatransform() {}

    // Takes a webcharts object creates a text annotation giving the

    function updateParticipantCount(chart, selector, id_unit) {
        //count the number of unique ids in the current chart and calculate the percentage
        var currentObs = d3
            .set(
                chart.filtered_data.map(function(d) {
                    return d[chart.config.id_col];
                })
            )
            .values().length;
        var percentage = d3.format('0.1%')(currentObs / chart.populationCount);

        //clear the annotation
        var annotation = d3.select(selector);
        d3.select(selector)
            .selectAll('*')
            .remove();

        //update the annotation
        var units = id_unit ? ' ' + id_unit : ' participant(s)';
        annotation.text(
            '\n' +
                currentObs +
                ' of ' +
                chart.populationCount +
                units +
                ' shown (' +
                percentage +
                ')'
        );
    }

    function resetRenderer() {
        //Reset listing.
        this.listing.draw([]);
        this.listing.wrap.selectAll('*').style('display', 'none');

        //Reset footnote.
        this.wrap
            .select('.annote')
            .classed('tableTitle', false)
            .text('Click a bar for details.');

        //Reset bar highlighting.
        delete this.highlightedBin;
        this.svg.selectAll('.bar').attr('opacity', 1);
    }

    function onDraw() {
        //Annotate population count.  This function is called on draw() so that it can access the
        //filtered data, i.e. the data with the current filters applied.  However the filtered data is
        //mark-specific, which could cause issues in other scenarios with mark-specific filters via the
        //marks.[].values setting.  chart.filtered_data is set to the last mark data defined rather
        //than the full data with filters applied, irrespective of the mark-specific filters.
        updateParticipantCount(this, '#populationCount');

        //Reset chart and listing.  Doesn't really need to be called on draw() but whatever.
        resetRenderer.call(this);
    }

    function handleSingleObservation() {
        this.svg.select('#custom-bin').remove();
        if (this.current_data.length === 1) {
            var datum = this.current_data[0];
            this.svg
                .append('g')
                .classed('bar-group', true)
                .attr('id', 'custom-bin')
                .append('rect')
                .data([datum])
                .classed('wc-data-mark bar', true)
                .attr({
                    y: 0,
                    height: this.plot_height,
                    'shape-rendering': 'crispEdges',
                    stroke: 'rgb(102,194,165)',
                    fill: 'rgb(102,194,165)',
                    'fill-opacity': '0.75',
                    width: this.x(datum.values.x * 1.01) - this.x(datum.values.x * 0.99),
                    x: this.x(datum.values.x * 0.99)
                });
        }
    }

    function addBinClickListener() {
        var chart = this;
        var config = this.config;
        var bins = this.svg.selectAll('.bar');
        var footnote = this.wrap.select('.annote');

        bins.style('cursor', 'pointer')
            .on('click', function(d) {
                chart.highlightedBin = d.key;
                //Update footnote.
                footnote
                    .classed('tableTitle', true)
                    .text(
                        'Table displays ' +
                            d.values.raw.length +
                            ' records with ' +
                            (chart.filtered_data[0][config.measure_col] + ' values from ') +
                            (chart.config.x.d3_format1(d.rangeLow) +
                                ' to ' +
                                chart.config.x.d3_format1(d.rangeHigh)) +
                            (config.unit_col ? ' ' + chart.filtered_data[0][config.unit_col] : '') +
                            '. Click outside a bar to remove details.'
                    );

                //Draw listing.
                chart.listing.draw(d.values.raw);
                chart.listing.wrap.selectAll('*').style('display', null);

                //Reduce bin opacity and highlight selected bin.
                bins.attr('fill-opacity', 0.5);
                d3.select(this).attr('fill-opacity', 1);
            })
            .on('mouseover', function(d) {
                //Update footnote.
                if (footnote.classed('tableTitle') === false)
                    footnote.text(
                        d.values.raw.length +
                            ' records with ' +
                            (chart.filtered_data[0][config.measure_col] + ' values from ') +
                            (chart.config.x.d3_format1(d.rangeLow) +
                                ' to ' +
                                chart.config.x.d3_format1(d.rangeHigh)) +
                            (config.unit_col ? ' ' + chart.filtered_data[0][config.unit_col] : '')
                    );
            })
            .on('mouseout', function(d) {
                //Update footnote.
                if (footnote.classed('tableTitle') === false)
                    footnote.text('Click a bar for details.');
            });
    }

    function drawNormalRanges() {
        var chart = this;
        var config = this.config;
        var normalRangeControl = this.controls.wrap.selectAll('.control-group').filter(function(d) {
            return d.label === 'Normal Range';
        });

        if (config.normal_range) {
            if (chart.config.displayNormalRange) drawNormalRanges(chart);
            else chart.wrap.selectAll('.normalRange').remove();

            normalRangeControl.on('change', function() {
                chart.config.displayNormalRange = d3
                    .select(this)
                    .select('input')
                    .property('checked');

                if (chart.config.displayNormalRange) drawNormalRanges(chart);
                else chart.wrap.selectAll('.normalRange').remove();
            });
        } else normalRangeControl.style('display', 'none');

        function drawNormalRanges() {
            //Clear normal ranges.
            var canvas = chart.svg;
            canvas.selectAll('.normalRange').remove();

            //Capture distinct normal ranges in filtered data.
            var normalRanges = d3
                .nest()
                .key(function(d) {
                    return d[chart.config.normal_col_low] + ',' + d[chart.config.normal_col_high];
                }) // set key to comma-delimited normal range
                .rollup(function(d) {
                    return d.length;
                })
                .entries(chart.filtered_data);
            var currentRange = d3.extent(chart.filtered_data, function(d) {
                return +d[chart.config.value_col];
            });
            //Sort normal ranges so larger normal ranges plot beneath smaller normal ranges.
            normalRanges.sort(function(a, b) {
                var a_lo = a.key.split(',')[0];
                var a_hi = a.key.split(',')[1];
                var b_lo = b.key.split(',')[0];
                var b_hi = b.key.split(',')[1];
                return a_lo <= b_lo && a_hi >= b_hi
                    ? 2 // lesser minimum and greater maximum
                    : a_lo >= b_lo && a_hi <= b_hi
                        ? -2 // greater minimum and lesser maximum
                        : a_lo <= b_lo && a_hi <= b_hi
                            ? 1 // lesser minimum and lesser maximum
                            : a_lo >= b_lo && a_hi >= b_hi
                                ? -1 // greater minimum and greater maximum
                                : 1;
            });
            //Add divs to chart for each normal range.
            canvas
                .selectAll('.normalRange rect')
                .data(normalRanges)
                .enter()
                .insert('rect', ':first-child')
                .attr({
                    class: 'normalRange',
                    x: function x(d) {
                        return chart.x(Math.max(+d.key.split(',')[0], currentRange[0]));
                    }, // set x to range low
                    y: 0,
                    width: function width(d) {
                        return Math.min(
                            chart.plot_width -
                                chart.x(Math.max(+d.key.split(',')[0], currentRange[0])), // chart width - range low

                            chart.x(+d.key.split(',')[1]) -
                                chart.x(Math.max(+d.key.split(',')[0], currentRange[0]))
                        );
                    }, // range high - range low

                    height: chart.plot_height
                })
                .style({
                    stroke: 'black',
                    fill: 'black',
                    'stroke-opacity': function strokeOpacity(d) {
                        return (d.values / chart.filtered_data.length) * 0.75;
                    }, // opacity as a function of fraction of records with the given normal range
                    'fill-opacity': function fillOpacity(d) {
                        return (d.values / chart.filtered_data.length) * 0.5;
                    }
                }) // opacity as a function of fraction of records with the given normal range
                .append('title')
                .text(function(d) {
                    return (
                        'Normal range: ' +
                        d.key.split(',')[0] +
                        '-' +
                        d.key.split(',')[1] +
                        (chart.config.unit_col
                            ? '' + chart.filtered_data[0][chart.config.unit_col]
                            : '') +
                        (' (' +
                            d3.format('%')(d.values / chart.filtered_data.length) +
                            ' of records)')
                    );
                });
        }
    }

    function addClearListing() {
        var chart = this;
        var footnote = this.wrap.select('.annote');
        this.wrap.selectAll('.overlay, .normalRange').on('click', function() {
            delete chart.highlightedBin;
            chart.listing.draw([]);
            chart.listing.wrap.selectAll('*').style('display', 'none');
            chart.svg.selectAll('.bar').attr('fill-opacity', 0.75);

            if (footnote.classed('tableTitle'))
                footnote.classed('tableTitle', false).text('Click a bar for details.');
        });
    }

    function maintainBinHighlighting() {
        var _this = this;

        if (this.highlightedBin)
            this.svg.selectAll('.bar').attr('fill-opacity', function(d) {
                return d.key !== _this.highlightedBin ? 0.5 : 1;
            });
    }

    function hideDuplicateXaxisTickLabels() {
        this.svg.selectAll('.x.axis .tick').each(function(d, i) {
            var tick = d3.select(this);
            var value = +d;
            var text = +tick.select('text').text();
            tick.style('display', value === text ? 'block' : 'none');
        });
    }

    function onResize() {
        //Draw custom bin for single observation subsets.
        handleSingleObservation.call(this);

        //Display data listing on bin click.
        addBinClickListener.call(this);

        //Visualize normal ranges.
        drawNormalRanges.call(this);

        //Clear listing when clicking outside bins.
        addClearListing.call(this);

        //Keep highlighted bin highlighted on resize.
        maintainBinHighlighting.call(this);

        //Hide duplicate x-axis tick labels (d3 sometimes draws more ticks than the precision allows).
        hideDuplicateXaxisTickLabels.call(this);
    }

    function onDestroy() {}

    //polyfills

    function safetyHistogram(element, settings) {
        //Define chart.
        var mergedSettings = Object.assign({}, defaultSettings, settings);
        var syncedSettings = syncSettings(mergedSettings);
        var syncedControlInputs = syncControlInputs(syncedSettings);
        var controls = webcharts.createControls(element, {
            location: 'top',
            inputs: syncedControlInputs
        });
        var chart = webcharts.createChart(element, syncedSettings, controls);

        //Define chart callbacks.
        chart.on('init', onInit);
        chart.on('layout', onLayout);
        chart.on('preprocess', onPreprocess);
        chart.on('datatransform', onDatatransform);
        chart.on('draw', onDraw);
        chart.on('resize', onResize);
        chart.on('destroy', onDestroy);

        //Define listing
        var listingSettings = {
            cols: syncedSettings.details.map(function(detail) {
                return detail.value_col;
            }),
            headers: syncedSettings.details.map(function(detail) {
                return detail.label;
            }),
            searchable: syncedSettings.searchable,
            sortable: syncedSettings.sortable,
            pagination: syncedSettings.pagination,
            exportable: syncedSettings.exportable
        };
        var listing = webcharts.createTable(element, listingSettings);

        //Attach listing to chart.
        chart.listing = listing;

        //Initialize listing and hide initially.
        chart.listing.init([]);
        chart.listing.wrap.selectAll('*').style('display', 'none');

        return chart;
    }

    return safetyHistogram;
});
