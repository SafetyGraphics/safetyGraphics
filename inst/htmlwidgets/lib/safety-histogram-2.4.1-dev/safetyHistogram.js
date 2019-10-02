(function(global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined'
        ? (module.exports = factory(require('d3'), require('webcharts')))
        : typeof define === 'function' && define.amd
            ? define(['d3', 'webcharts'], factory)
            : (global.safetyHistogram = factory(global.d3, global.webCharts));
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

    Math.log10 = Math.log10 =
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
            //required variables
            measure_col: 'TEST',
            value_col: 'STRESN',

            //optional variables
            id_col: 'USUBJID',
            unit_col: 'STRESU',
            normal_col_low: 'STNRLO',
            normal_col_high: 'STNRHI',
            filters: null,
            details: null,

            //miscellaneous settings
            start_value: null,
            normal_range: true,
            displayNormalRange: false,
            bin_algorithm: "Scott's normal reference rule",
            annotate_bin_boundaries: false
        };
    }

    function webchartsSettings() {
        return {
            x: {
                type: 'linear',
                column: null, // set in ./syncSettings
                label: null, // set in ../callbacks/onPreprocess/setXaxisLabel
                domain: [null, null], // set in ../callbacks/onPreprocess/setXdomain
                format: null, // set in ../callbacks/onPreprocess/calculateXPrecision
                bin: null // set in ../callbacks/onPreprocess/defineMeasureData
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
                    per: [], // set in ./syncSettings
                    type: 'bar',
                    summarizeX: 'mean',
                    summarizeY: 'count',
                    attributes: { 'fill-opacity': 0.75 }
                }
            ],
            aspect: 3
        };
    }

    function syncSettings(settings) {
        settings.x.column = settings.value_col;
        settings.x.bin_algorithm = settings.bin_algorithm;
        settings.marks[0].per[0] = settings.value_col;

        //update normal range settings if normal_range is set to false
        if (!settings.normal_range) {
            settings.normal_col_low = null;
            settings.normal_col_high = null;
            settings.displayNormalRange = false;
        }

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
                .filter(function(filter) {
                    return filter.value_col !== settings.id_col;
                })
                .forEach(function(filter) {
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

    function controlInputs() {
        return [
            {
                type: 'subsetter',
                value_col: 'sh_measure',
                label: 'Measure',
                start: null // set in ../callbacks/onInit/checkControls/updateMeasureFilter
            },
            {
                type: 'number',
                option: 'x.domain[0]',
                label: 'Lower',
                require: true
            },
            {
                type: 'number',
                option: 'x.domain[1]',
                label: 'Upper',
                require: true
            },
            {
                type: 'dropdown',
                option: 'x.bin_algorithm',
                label: 'Algorithm',
                values: [
                    'Square-root choice',
                    "Sturges' formula",
                    'Rice Rule',
                    //'Doane\'s formula',
                    "Scott's normal reference rule",
                    "Freedman-Diaconis' choice",
                    "Shimazaki and Shinomoto's choice",
                    'Custom'
                ],
                require: true
            },
            {
                type: 'number',
                option: 'x.bin',
                label: 'Quantity'
            },
            {
                type: 'number',
                option: 'x.bin_width',
                label: 'Width'
            },
            {
                type: 'checkbox',
                option: 'displayNormalRange',
                label: 'Normal Range'
            },
            {
                type: 'radio',
                option: 'annotate_bin_boundaries',
                label: 'X-axis Ticks',
                values: [false, true],
                relabels: ['linear', 'bin boundaries']
            }
        ];
    }

    function syncControlInputs(controlInputs, settings) {
        //Add filters to default controls.
        if (Array.isArray(settings.filters) && settings.filters.length > 0) {
            var position = controlInputs.findIndex(function(input) {
                return input.label === 'Algorithm';
            });
            settings.filters.forEach(function(filter) {
                var filterObj = {
                    type: 'subsetter',
                    value_col: filter.value_col || filter,
                    label: filter.label || filter.value_col || filter
                };
                controlInputs.splice(position, 0, filterObj);
                ++position;
            });
        }

        //Remove normal range control.
        if (!settings.normal_range)
            controlInputs.splice(
                controlInputs.findIndex(function(input) {
                    return input.label === 'Normal Range';
                }),
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

    var properties = {
        measure_col: {
            title: 'Medical Sign',
            description: 'a variable that contains the names of each medical sign',
            type: 'string',
            default: 'TEST',
            'data-mapping': true,
            'data-type': 'character',
            required: true
        },
        value_col: {
            title: 'Result',
            description:
                'a variable that contains the results for each medical sign; non-numeric results are removed with a notification thrown to the log',
            type: 'string',
            default: 'STRESN',
            'data-mapping': true,
            'data-type': 'numeric',
            required: true
        },
        id_col: {
            title: 'ID',
            description: 'a variable that contains IDs for each participant',
            type: 'string',
            default: 'USUBJID',
            'data-mapping': true,
            'data-type': 'character',
            required: false
        },
        unit_col: {
            title: 'Unit',
            description: 'a variable that contains the units of each medical sign',
            type: 'string',
            default: 'STRESU',
            'data-mapping': true,
            'data-type': 'character',
            required: false
        },
        normal_col_low: {
            title: 'Lower Limit of Normal',
            description: 'a variable that contains the lower limit of normal of the medical sign',
            type: 'string',
            default: 'STNRLO',
            'data-mapping': true,
            'data-type': 'numeric',
            required: false
        },
        normal_col_high: {
            title: 'Upper Limit of Normal',
            description: 'a variable that contains the upper limit of normal of the medical sign',
            type: 'string',
            default: 'STNRHI',
            'data-mapping': true,
            'data-type': 'numeric',
            required: false
        },
        filters: {
            title: 'Filter Variables',
            description:
                'an array of variables and metadata that will appear in the controls as data filters',
            type: 'array',
            items: {
                properties: {
                    label: {
                        description: 'a description of the variable',
                        title: 'Variable Label',
                        type: 'string'
                    },
                    value_col: {
                        description: 'the name of the variable',
                        title: 'Variable Name',
                        type: 'string'
                    }
                },
                type: 'object'
            },
            'data-mapping': true,
            'data-type': 'either',
            required: false
        },
        details: {
            title: 'Listing Variables',
            description: 'an array of variables and metadata that will appear in the data listing',
            type: 'array',
            items: {
                properties: {
                    label: {
                        description: 'a description of the variable',
                        title: 'Variable Label',
                        type: 'string'
                    },
                    value_col: {
                        description: 'the name of the variable',
                        title: 'Variable Name',
                        type: 'string'
                    }
                },
                type: 'object'
            },
            'data-mapping': true,
            'data-type': 'either',
            required: false
        },
        start_value: {
            title: 'Initial Medical Sign',
            description:
                'the name of the initially displayed medical sign; defaults to the first measure in the data',
            type: 'string'
        },
        normal_range: {
            title: 'Generate Normal Range Control?',
            description:
                'a boolean that dictates whether the normal range control will be generated',
            type: 'boolean',
            default: true
        },
        displayNormalRange: {
            title: 'Display Normal Range?',
            description:
                'a boolean that dictates whether the normal range will be displayed initially',
            type: 'boolean',
            default: false
        }
    };

    function checkRequired() {
        var _this = this;

        this.variables.required = this.variables.definitions.filter(function(definition) {
            return definition.required === true;
        });
        this.variables.required.forEach(function(definition) {
            if (_this.variables.actual.indexOf(definition.setting) < 0) {
                definition.missing = true;

                //Define error text.
                var codeStyle = [
                    'padding: 1px 5px',
                    'white-space: prewrap',
                    'font-family: Consolas,Lucida Console,Courier New,monospace,sans-serif',
                    'background-color: #eff0f1'
                ];
                var errorText =
                    "The variable specified for <code style='" +
                    codeStyle.join(';') +
                    "'>" +
                    definition.property +
                    '</code>, <em>' +
                    definition.setting +
                    '</em>, does not exist in the data.';

                //Print error to console.
                console.error(errorText.replace(/<.+?>/g, ''));

                //Print error to containing element.
                var div = d3.select(_this.div);
                div.append('p')
                    .html(errorText)
                    .style('color', 'red');
            }
        });

        //Destroy chart.
        if (
            this.variables.required.some(function(definition) {
                return definition.missing;
            })
        )
            this.destroy();
    }

    function checkOptional() {
        var _this = this;

        this.variables.optional = this.variables.definitions.filter(function(definition) {
            return definition.required === false;
        });

        this.variables.optional.forEach(function(definition) {
            if (definition.type === 'string') {
                if (_this.variables.actual.indexOf(definition.setting) < 0) {
                    definition.missing = true;
                    console.warn(
                        'The variable specified for [ ' +
                            definition.property +
                            ' ], ' +
                            definition.setting +
                            ', does not exist in the data.'
                    );
                }
            } // standard data mappings
            else if (
                definition.type === 'array' &&
                Array.isArray(definition.setting) &&
                definition.setting.length
            ) {
                definition.setting.forEach(function(subDefinition, i) {
                    var variable = subDefinition.value_col || subDefinition;
                    if (_this.variables.actual.indexOf(variable) < 0) {
                        definition.missing = true;
                        console.warn(
                            'The variable specified for [ ' +
                                definition.property +
                                '[' +
                                i +
                                '] ], ' +
                                variable +
                                ', does not exist in the data.'
                        );
                    }
                });
            } // optional variable arrays (filters, listing columns)

            //Remove participant ID column from listing if variable is missing.
            if (definition.property === 'id_col' && definition.missing) {
                var index = _this.listing.config.cols.findIndex(function(col) {
                    return col === definition.setting;
                });
                _this.listing.config.cols.splice(index, 1);
                _this.listing.config.headers.splice(index, 1);
            }
        });
    }

    function checkVariables() {
        var _this = this;

        this.variables = {
            actual: Object.keys(this.raw_data[0]),
            definitions: Object.keys(properties)
                .map(function(property) {
                    var definition = properties[property];
                    definition.property = property;
                    definition.setting = _this.config[property];
                    return definition;
                })
                .filter(function(definition) {
                    return definition['data-mapping'];
                })
        };
        checkRequired.call(this);
        checkOptional.call(this);
    }

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

        this.raw_data.forEach(function(d) {
            //Concatenate unit to measure if provided.
            d[_this.config.measure_col] = d[_this.config.measure_col].trim();
            d.sh_measure = d.hasOwnProperty(_this.config.unit_col)
                ? d[_this.config.measure_col] + ' (' + d[_this.config.unit_col] + ')'
                : d[_this.config.measure_col];
        });
    }

    function participant() {
        var _this = this;

        this.participants = d3
            .set(
                this.initial_data.map(function(d) {
                    return d[_this.config.id_col];
                })
            )
            .values()
            .sort();
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
        this.sh_measures = d3
            .set(
                this.initial_data.map(function(d) {
                    return d.sh_measure;
                })
            )
            .values()
            .sort();
    }

    function defineSets() {
        participant.call(this);
        measure.call(this);
    }

    function updateMeasureFilter() {
        this.measure = {};
        var measureInput = this.controls.config.inputs.find(function(input) {
            return input.label === 'Measure';
        });
        if (
            this.config.start_value &&
            this.sh_measures.indexOf(this.config.start_value) < 0 &&
            this.measures.indexOf(this.config.start_value) < 0
        ) {
            measureInput.start = this.sh_measures[0];
            console.warn(
                this.config.start_value +
                    ' is an invalid measure. Defaulting to ' +
                    measureInput.start +
                    '.'
            );
        } else if (
            this.config.start_value &&
            this.sh_measures.indexOf(this.config.start_value) < 0
        ) {
            measureInput.start = this.sh_measures[this.measures.indexOf(this.config.start_value)];
            console.warn(
                this.config.start_value +
                    ' is missing the units value. Defaulting to ' +
                    measureInput.start +
                    '.'
            );
        } else measureInput.start = this.config.start_value || this.sh_measures[0];
    }

    function removeFilters() {
        var _this = this;

        this.controls.config.inputs = this.controls.config.inputs.filter(function(input) {
            if (input.type !== 'subsetter' || input.value_col === 'sh_measure') {
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

    function checkControls() {
        updateMeasureFilter.call(this);
        removeFilters.call(this);
    }

    function onInit() {
        // 0. Check variables.
        checkVariables.call(this);

        // 1. Count total participants prior to data cleaning.
        countParticipants.call(this);

        // 2. Drop missing values and remove measures with any non-numeric results.
        cleanData.call(this);

        // 3. Define additional variables.
        addVariables.call(this);

        // 4. Define sets.
        defineSets.call(this);

        // 5. Check controls.
        checkControls.call(this);
    }

    function identifyControls() {
        var context = this;

        var controlGroups = this.controls.wrap
            .style('padding-bottom', '8px')
            .selectAll('.control-group');

        //Give each control a unique ID.
        controlGroups
            .attr('id', function(d) {
                return d.label.toLowerCase().replace(/ /g, '-');
            })
            .each(function(d) {
                var controlGroup = d3.select(this);
                controlGroup.classed(d.type, true);
                context.controls[d.label] = controlGroup;
            });

        //Give x-axis controls a common class name.
        controlGroups
            .filter(function(d) {
                return ['x.domain[0]', 'x.domain[1]'].indexOf(d.option) > -1;
            })
            .classed('x-axis', true);

        //Give binning controls a common class name.
        controlGroups
            .filter(function(d) {
                return ['x.bin_algorithm', 'x.bin', 'x.bin_width'].indexOf(d.option) > -1;
            })
            .classed('bin', true);
    }

    function addXdomainResetButton() {
        var _this = this;

        //Add x-domain reset button container.
        this.controls.reset = {
            container: this.controls.wrap
                .insert('div', '#lower')
                .classed('control-group x-axis', true)
                .datum({
                    type: 'button',
                    option: 'x.domain',
                    label: ''
                })
                .style('vertical-align', 'bottom')
        };

        //Add label.
        this.controls.reset.label = this.controls.reset.container
            .append('span')
            .attr('class', 'wc-control-label')
            .text('');

        //Add button.
        this.controls.reset.button = this.controls.reset.container
            .append('button')
            .text(' Reset ')
            .style('padding', '0px 5px')
            .on('click', function() {
                _this.config.x.domain = _this.measure.raw.domain;

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

    function insertGrouping(selector, label) {
        var className = label.toLowerCase().replace(/ /g, '-') + '-grouping';
        var div = this.controls.wrap
            .insert('div', selector)
            .classed(className + '-div', true)
            .style({
                display: 'inline-block',
                'margin-right': '5px'
            });
        var fieldset = div
            .append('fieldset')
            .classed(className + '-fieldset', true)
            .style('padding', '0px 2px');
        var legend = fieldset
            .append('legend')
            .classed(className + '-legend', true)
            .text(label);
        this.controls.wrap.selectAll(selector).each(function(d) {
            this.style.marginTop = '0px';
            this.style.marginRight = '2px';
            this.style.marginBottom = '2px';
            this.style.marginLeft = '2px';
            fieldset.node().appendChild(this);
        });
    }

    function groupControls() {
        //Group x-axis controls.
        insertGrouping.call(this, '.x-axis', 'X-axis Limits');

        //Group filters.
        if (this.filters.length > 1)
            insertGrouping.call(this, '.subsetter:not(#measure)', 'Filters');

        //Group bin controls.
        insertGrouping.call(this, '.bin', 'Bins');
    }

    function addXdomainZoomButton() {
        var _this = this;

        if (
            this.filters.find(function(filter) {
                return filter.col !== 'sh_measure';
            })
        ) {
            //Add x-domain zoom button container.
            var resetContainer = this.controls.wrap
                .select('.x-axis-limits-grouping-fieldset')
                .append('div')
                .classed('control-group x-axis', true)
                .datum({
                    type: 'button',
                    option: 'x.domain',
                    label: ''
                })
                .attr('title', 'Zoom in on filtered histogram.')
                .style({
                    'vertical-align': 'bottom',
                    'margin-top': '0px',
                    'margin-right': '2px',
                    'margin-bottom': '2px',
                    'margin-left': '2px'
                });

            //Add label.
            resetContainer
                .append('span')
                .attr('class', 'wc-control-label')
                .text('');

            //Add button.
            resetContainer
                .append('button')
                .text(' Zoom ')
                .style('padding', '0px 5px')
                .on('click', function() {
                    _this.config.x.domain = _this.measure.filtered.domain;

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
    }

    function customizeBinsEventListener() {
        var _this = this;

        var context = this;

        this.controls.Algorithm.selectAll('.wc-control-label')
            .append('span')
            .classed('algorithm-explanation', true)
            .html(' &#9432')
            .style('cursor', 'pointer')
            .on('click', function() {
                if (_this.config.x.bin_algorithm !== 'Custom')
                    window.open(
                        'https://en.wikipedia.org/wiki/Histogram#' +
                            _this.config.x.bin_algorithm
                                .replace(/ /g, '_')
                                .replace('Freedman-Diaconis', 'Freedman%E2%80%93Diaconis')
                    );
            });

        this.controls.Quantity.selectAll('input')
            .attr({
                min: 1,
                step: 1
            })
            .on('change', function(d) {
                if (this.value < 1) this.value = 1;
                if (this.value % 1) this.value = Math.round(this.value);
                context.config.x.bin = this.value;
                context.config.x.bin_algorithm = 'Custom';
                context.controls.Algorithm.selectAll('option').property('selected', function(di) {
                    return di === 'Custom';
                });
                context.draw();
            });

        this.controls.Width.selectAll('input').property('disabled', true);
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
                left: 0,
                display: this.variables.optional.find(function(definition) {
                    return definition.property === 'id_col';
                }).missing
                    ? 'none'
                    : 'block'
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

    function addFootnoteContainer() {
        this.footnotes = {
            container: this.wrap
                .insert('div', '.wc-chart')
                .classed('footnotes', true)
                .style({
                    'border-top': '1px solid #ccc',
                    'padding-top': '10px'
                })
        };
        this.footnotes.barClick = this.footnotes.container
            .append('p')
            .classed('footnote footnote--bar-click', true)
            .text('Click a bar for details.');
        this.footnotes.barDetails = this.footnotes.container
            .append('p')
            .classed('footnote footnote--bar-details', true);
    }

    function preventWhiteSpaceWrap() {
        //Style table
        this.listing.table.style('white-space', 'nowrap');
    }

    function onLayout() {
        identifyControls.call(this);
        addXdomainResetButton.call(this);
        groupControls.call(this);
        addXdomainZoomButton.call(this);
        customizeBinsEventListener.call(this);
        addParticipantCountContainer.call(this);
        addRemovedRecordsNote.call(this);
        addBorderAboveChart.call(this);
        addFootnoteContainer.call(this);
        preventWhiteSpaceWrap.call(this);
    }

    function getCurrentMeasure() {
        this.measure.previous = this.measure.current;
        this.measure.current = this.controls.wrap.selectAll('#measure option:checked').text();
        this.config.x.label = this.measure.current;
        if (this.measure.current !== this.measure.previous) this.config.x.custom_bin = false;
    }

    function defineMeasureData() {
        var _this = this;

        //Filter data on selected measure.
        this.measure.raw = {
            data: this.initial_data.filter(function(d) {
                return d.sh_measure === _this.measure.current;
            })
        };

        //Apply other filters to measure data.
        this.measure.filtered = {
            data: this.measure.raw.data
        };
        this.filters.forEach(function(filter) {
            _this.measure.filtered.data = _this.measure.filtered.data.filter(function(d) {
                return filter.val === 'All'
                    ? true
                    : Array.isArray(filter.val)
                        ? filter.val.includes(d[filter.col])
                        : filter.val === d[filter.col];
            });
        });

        //Filter results on current x-domain.
        if (this.measure.current !== this.measure.previous)
            this.config.x.domain = d3.extent(
                this.measure.raw.data.map(function(d) {
                    return +d[_this.config.value_col];
                })
            );
        this.measure.custom = {
            data: this.measure.raw.data.filter(function(d) {
                return (
                    _this.config.x.domain[0] <= +d[_this.config.value_col] &&
                    +d[_this.config.value_col] <= _this.config.x.domain[1]
                );
            })
        };

        //Define arrays of results, unique results, and extent of results.
        ['raw', 'custom', 'filtered'].forEach(function(property) {
            var obj = _this.measure[property];

            //Define array of all and unique results.
            obj.results = obj.data
                .map(function(d) {
                    return +d[_this.config.value_col];
                })
                .sort(function(a, b) {
                    return a - b;
                });
            obj.uniqueResults = d3.set(obj.results).values();

            //Calculate extent of data.
            obj.domain = property !== 'custom' ? d3.extent(obj.results) : _this.config.x.domain;
        });
    }

    function setXdomain() {
        if (this.measure.current !== this.measure.previous)
            this.config.x.domain = this.measure.raw.domain;
        else if (this.config.x.domain[0] > this.config.x.domain[1]) this.config.x.domain.reverse();

        //The x-domain can be in three states:
        //- the extent of all results
        //- user-defined, e.g. narrower to exclude outliers
        //
        //Bin width is calculated with two variables:
        //- the interquartile range
        //- the number of results
        //
        //1 When the x-domain is set to the extent of all results, the bin width should be calculated
        //  with the unfiltered set of results, regardless of the state of the current filters.
        //
        //2 Given a user-defined x-domain, the bin width should be calculated with the results that
        //  fall inside the current domain.
        this.measure.domain_state =
            (this.config.x.domain[0] === this.measure.raw.domain[0] &&
                this.config.x.domain[1] === this.measure.raw.domain[1]) ||
            this.measure.previous === undefined
                ? 'raw'
                : 'custom';

        //Set chart data to measure data.
        this.raw_data = this.measure[this.measure.domain_state].data.slice();
    }

    function calculateStatistics(obj) {
        var _this = this;

        ['raw', 'custom'].forEach(function(property) {
            var obj = _this.measure[property];

            //Calculate statistics.
            obj.stats = {
                n: obj.results.length,
                nUnique: obj.uniqueResults.length,
                min: obj.domain[0],
                q25: d3.quantile(obj.results, 0.25),
                median: d3.quantile(obj.results, 0.5),
                q75: d3.quantile(obj.results, 0.75),
                max: obj.domain[1],
                range: obj.domain[1] - obj.domain[0],
                std: d3.deviation(obj.results)
            };
            obj.stats.log10range = obj.stats.range > 0 ? Math.log10(obj.stats.range) : NaN;
            obj.stats.iqr = obj.stats.q75 - obj.stats.q25;
        });
    }

    function calculateSquareRootBinWidth(obj) {
        //https://en.wikipedia.org/wiki/Histogram#Square-root_choice
        var range = this.config.x.domain[1] - this.config.x.domain[0];
        obj.stats.SquareRootBins = Math.ceil(Math.sqrt(obj.stats.n));
        obj.stats.SquareRootBinWidth = range / obj.stats.SquareRootBins;
    }

    function calculateSturgesBinWidth(obj) {
        //https://en.wikipedia.org/wiki/Histogram#Sturges'_formula
        var range = this.config.x.domain[1] - this.config.x.domain[0];
        obj.stats.SturgesBins = Math.ceil(Math.log2(obj.stats.n)) + 1;
        obj.stats.SturgesBinWidth = range / obj.stats.SturgesBins;
    }

    function calculateRiceBinWidth(obj) {
        //https://en.wikipedia.org/wiki/Histogram#Rice_Rule
        var range = this.config.x.domain[1] - this.config.x.domain[0];
        obj.stats.RiceBins = Math.ceil(2 * Math.pow(obj.stats.n, 1.0 / 3.0));
        obj.stats.RiceBinWidth = range / obj.stats.RiceBins;
    }

    function calculateScottBinWidth(obj) {
        //https://en.wikipedia.org/wiki/Histogram#Scott's_normal_reference_rule
        var range = this.config.x.domain[1] - this.config.x.domain[0];
        obj.stats.ScottBinWidth = (3.5 * obj.stats.std) / Math.pow(obj.stats.n, 1.0 / 3.0);
        obj.stats.ScottBins =
            obj.stats.ScottBinWidth > 0
                ? Math.max(Math.ceil(range / obj.stats.ScottBinWidth), 5)
                : NaN;
    }

    function calculateFDBinWidth(obj) {
        //https://en.wikipedia.org/wiki/Histogram#Freedman%E2%80%93Diaconis'_choice
        var range = this.config.x.domain[1] - this.config.x.domain[0];
        obj.stats.FDBinWidth = (2 * obj.stats.iqr) / Math.pow(obj.stats.n, 1.0 / 3.0);
        obj.stats.FDBins =
            obj.stats.FDBinWidth > 0 ? Math.max(Math.ceil(range / obj.stats.FDBinWidth), 5) : NaN;
    }

    var toConsumableArray = function(arr) {
        if (Array.isArray(arr)) {
            for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i];

            return arr2;
        } else {
            return Array.from(arr);
        }
    };

    function calculateSSBinWidth(obj) {
        //https://en.wikipedia.org/wiki/Histogram#Shimazaki_and_Shinomoto's_choice
        var nBins = d3.range(2, 100); // number of bins
        var cost = d3.range(nBins.length); // cost function results
        var binWidths = [].concat(toConsumableArray(cost)); // bin widths
        var binBoundaries = [].concat(toConsumableArray(cost)); // bin boundaries
        var bins = [].concat(toConsumableArray(cost)); // bins
        var binSizes = [].concat(toConsumableArray(cost)); // bin lengths
        var meanBinSizes = [].concat(toConsumableArray(cost)); // mean of bin lengths
        var residuals = [].concat(toConsumableArray(cost)); // residuals

        var _loop = function _loop(i) {
            binWidths[i] = obj.stats.range / nBins[i];
            binBoundaries[i] = d3.range(obj.stats.min, obj.stats.max, obj.stats.range / nBins[i]);
            bins[i] = d3.layout.histogram().bins(nBins[i] - 1)(
                /*.bins(binBoundaries[i])*/ obj.results
            );
            binSizes[i] = bins[i].map(function(arr) {
                return arr.length;
            });
            meanBinSizes[i] = d3.mean(binSizes[i]);
            residuals[i] =
                d3.sum(
                    binSizes[i].map(function(binSize) {
                        return Math.pow(binSize - meanBinSizes[i], 2);
                    })
                ) / nBins[i];
            cost[i] = (2 * meanBinSizes[i] - residuals[i]) / Math.pow(binWidths[i], 2);
        };

        for (var i = 0; i < nBins.length; i++) {
            _loop(i);
        }

        //consoleLogVars(
        //    {
        //        nBins,
        //        binWidths,
        //        binBoundaries,
        //        //bins,
        //        binSizes,
        //        meanBinSizes,
        //        residuals,
        //        cost
        //    },
        //    5
        //);

        var minCost = d3.min(cost);
        var idx = cost.findIndex(function(c) {
            return c === minCost;
        });

        obj.stats.SSBinWidth = binWidths[idx];
        obj.stats.SSBins = nBins[idx];
        //const optBinBoundaries = range(obj.stats.min, obj.stats.max, obj.stats.range/optNBins);
    }

    function calcualteBinWidth() {
        var _this = this;

        ['raw', 'custom'].forEach(function(property) {
            var obj = _this.measure[property];

            //Calculate bin width with the selected algorithm.
            switch (_this.config.x.bin_algorithm) {
                case 'Square-root choice':
                    calculateSquareRootBinWidth.call(_this, obj);
                    obj.stats.nBins =
                        obj.stats.SquareRootBins < obj.stats.nUnique
                            ? obj.stats.SquareRootBins
                            : obj.stats.nUnique;
                    break;
                case "Sturges' formula":
                    calculateSturgesBinWidth.call(_this, obj);
                    obj.stats.nBins =
                        obj.stats.SturgesBins < obj.stats.nUnique
                            ? obj.stats.SturgesBins
                            : obj.stats.nUnique;
                    break;
                case 'Rice Rule':
                    calculateRiceBinWidth.call(_this, obj);
                    obj.stats.nBins =
                        obj.stats.RiceBins < obj.stats.nUnique
                            ? obj.stats.RiceBins
                            : obj.stats.nUnique;
                    break;
                //case 'Doane\'s formula':
                //    console.log(4);
                //    calculateDoaneBinWidth.call(this, obj);
                //    obj.stats.nBins =
                //        obj.stats.DoaneBins < obj.stats.nUnique ? obj.stats.DoaneBins : obj.stats.nUnique;
                //    break;
                case "Scott's normal reference rule":
                    calculateScottBinWidth.call(_this, obj);
                    obj.stats.nBins =
                        obj.stats.ScottBins < obj.stats.nUnique
                            ? obj.stats.ScottBins
                            : obj.stats.nUnique;
                    break;
                case "Freedman-Diaconis' choice":
                    calculateFDBinWidth.call(_this, obj);
                    obj.stats.nBins =
                        obj.stats.FDBins < obj.stats.nUnique ? obj.stats.FDBins : obj.stats.nUnique;
                    break;
                case "Shimazaki and Shinomoto's choice":
                    calculateSSBinWidth.call(_this, obj);
                    obj.stats.nBins =
                        obj.stats.SSBins < obj.stats.nUnique ? obj.stats.SSBins : obj.stats.nUnique;
                    break;
                default:
                    //Handle custom number of bins.
                    obj.stats.nBins = _this.config.x.bin;
                //obj.stats.binWidth = this.config.x.domain[1] - this.config.x.domain[0] / this.config.x.bin;
            }

            //Calculate bin width.
            obj.stats.binWidth = obj.stats.range / obj.stats.nBins;
            obj.stats.binBoundaries = d3.range(obj.stats.nBins).concat(obj.domain[1]);
        });

        //Update chart config and set chart data to measure data.
        this.config.x.bin = this.measure[this.measure.domain_state].stats.nBins;
        this.config.x.bin_width = this.measure[this.measure.domain_state].stats.binWidth;
    }

    function calculateXPrecision() {
        //define the precision of the x-axis
        this.config.x.precisionFactor = Math.round(
            this.measure[this.measure.domain_state].stats.log10range
        );
        this.config.x.precision = Math.pow(10, this.config.x.precisionFactor);

        //x-axis format
        this.config.x.format =
            this.config.x.precisionFactor > 0
                ? '.0f'
                : '.' + (Math.abs(this.config.x.precisionFactor) + 1) + 'f';
        this.config.x.d3format = d3.format(this.config.x.format);

        //one more precision please: bin format
        this.config.x.format1 =
            this.config.x.precisionFactor > 0
                ? '.1f'
                : '.' + (Math.abs(this.config.x.precisionFactor) + 2) + 'f';
        this.config.x.d3format1 = d3.format(this.config.x.format1);

        //define the size of the x-axis limit increments
        var step =
            this.measure[this.measure.domain_state].stats.range > 0
                ? Math.abs(this.measure[this.measure.domain_state].stats.range / 15) // non-zero range
                : this.measure[this.measure.domain_state].results[0] !== 0
                    ? Math.abs(this.measure[this.measure.domain_state].results[0] / 15) // zero range, non-zero result(s)
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

    function updateXAxisResetButton() {
        //Update tooltip of x-axis domain reset button.
        if (this.measure.current !== this.measure.previous) {
            this.controls.reset.container.attr(
                'title',
                'Initial Limits: [' +
                    this.config.x.d3format1(this.config.x.domain[0]) +
                    ' - ' +
                    this.config.x.d3format1(this.config.x.domain[1]) +
                    ']'
            );
        }
    }

    function updateXAxisLimits() {
        this.controls.wrap
            .selectAll('#lower input')
            .attr('step', this.measure.step) // set in ./calculateXPrecision
            .style('box-shadow', 'none')
            .property('value', this.config.x.d3format1(this.config.x.domain[0]));

        this.controls.wrap
            .selectAll('#upper input')
            .attr('step', this.measure.step) // set in ./calculateXPrecision
            .style('box-shadow', 'none')
            .property('value', this.config.x.d3format1(this.config.x.domain[1]));
    }

    function updateBinAlogrithm() {
        this.controls.Algorithm.selectAll('.algorithm-explanation')
            .style('display', this.config.x.bin_algorithm !== 'Custom' ? null : 'none')
            .attr(
                'title',
                this.config.x.bin_algorithm !== 'Custom'
                    ? 'View information on ' + this.config.x.bin_algorithm
                    : null
            );
    }

    function updateBinWidth() {
        this.controls.Width.selectAll('input').property(
            'value',
            this.config.x.d3format1(this.config.x.bin_width)
        );
    }

    function updateBinQuantity() {
        this.controls.Quantity.selectAll('input').property('value', this.config.x.bin);
    }

    function updateControls() {
        updateXAxisResetButton.call(this);
        updateXAxisLimits.call(this);
        updateBinAlogrithm.call(this);
        updateBinWidth.call(this);
        updateBinQuantity.call(this);
    }

    function defineBinBoundaries() {
        var _this = this;

        var obj = this.measure[this.measure.domain_state];
        this.measure.binBoundaries = obj.stats.binBoundaries.map(function(d, i) {
            var value = obj.domain[0] + obj.stats.binWidth * i;
            return {
                value: value,
                value1: _this.config.x.d3format(value),
                value2: _this.config.x.d3format1(value)
            };
        });
    }

    function onPreprocess() {
        // 1. Capture currently selected measure - needed in 2a.
        getCurrentMeasure.call(this);

        // 2. Filter data on currently selected measure - needed in 3a and 3b.
        defineMeasureData.call(this);

        // 3a Set x-domain given currently selected measure - needed in 4a and 4b.
        setXdomain.call(this);

        // 3b Calculate statistics - needed in 4a and 4b.
        calculateStatistics.call(this);

        // 4a Define precision of measure - needed in step 5a and 5b.
        calculateXPrecision.call(this);

        // 4b Calculate bin width - needed in step 5c.
        calcualteBinWidth.call(this);

        // 5a Update x-axis and bin controls after.
        updateControls.call(this);

        // 5b Define bin boundaries given bin width and precision.
        defineBinBoundaries.call(this);
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

    function resetRenderer() {
        delete this.highlightedBin;
        delete this.highlighteD;

        //Remove bin boundaries.
        this.svg.select('g.bin-boundaries').remove();

        //Reset bar highlighting.
        this.svg
            .selectAll('.bar-group')
            .classed('selected', false)
            .selectAll('.bar')
            .attr('fill-opacity', 0.75);

        //Reset footnotes.
        this.footnotes.barClick
            .style({
                'text-decoration': 'none',
                cursor: 'normal'
            })
            .text('Click a bar for details.');
        this.footnotes.barDetails.text('');

        //Reset listing.
        this.listing.draw([]);
        this.listing.wrap.style('display', 'none');
    }

    function increasePrecision() {
        var _this = this;

        var ticks = this.x.ticks().map(function(d) {
            return _this.config.x.d3format(d);
        });
        if (
            d3
                .nest()
                .key(function(d) {
                    return d;
                })
                .rollup(function(d) {
                    return d.length;
                })
                .entries(ticks)
                .some(function(d) {
                    return d.values > 1;
                })
        )
            this.config.x.format = this.config.x.format1;
    }

    function onDraw() {
        updateParticipantCount.call(this);
        resetRenderer.call(this);
        increasePrecision.call(this);
    }

    function drawZeroRangeBar() {
        var _this = this;

        if (
            this.current_data.length === 1 &&
            this.measure.filtered.domain[0] === this.measure.filtered.domain[1]
        ) {
            var width = this.plot_width / 25;
            this.svg
                .selectAll('g.bar-group rect')
                .transition()
                .delay(250) // wait for initial marks to transition
                .attr({
                    x: function x(d) {
                        return _this.x(d.values.x) - width / 2;
                    },
                    width: width
                });
        }
    }

    function addHoverBars() {
        var context = this;

        var bins = this.svg.selectAll('.bar-group').each(function(d) {
            var g = d3.select(this);
            g.selectAll('.hover-bar').remove();

            //Drawing a path instead of a rect because Webcharts messes up the original rect on resize.
            var x = context.x(d.rangeLow);
            var y = 0;
            var width = context.x(d.rangeHigh) - context.x(d.rangeLow);
            var height = context.plot_height;
            var hoverBar = g
                .insert('path', ':first-child')
                .classed('hover-bar', true)
                .attr({
                    d: 'M ' + x + ' ' + y + ' V ' + height + ' H ' + (x + width) + ' V ' + y,
                    fill: 'black',
                    'fill-opacity': 0,
                    stroke: 'black',
                    'stroke-opacity': 0
                });
            d.footnote =
                "<span style = 'font-weight: bold'>" +
                d.values.raw.length +
                ' records</span> with ' +
                (context.measure.current + " values &ge;<span style = 'font-weight: bold'>") +
                (context.config.x.d3format1(d.rangeLow) +
                    '</span> and ' +
                    (d.rangeHigh < context.config.x.domain[1] ? '&lt;' : '&le;') +
                    "<span style = 'font-weight: bold'>" +
                    context.config.x.d3format1(d.rangeHigh) +
                    '</span>');
        });
    }

    function mouseout(element, d) {
        //Update footnote.
        this.footnotes.barDetails.html(
            this.highlightedBin ? 'Table displays ' + this.highlighteD.footnote + '.' : ''
        );

        //Remove bar highlight.
        var selection = d3.select(element);
        selection.selectAll('.bar').attr('stroke', this.colorScale());
    }

    function mouseover(element, d) {
        //Update bar details footnote.
        this.footnotes.barDetails.html('Bar encompasses ' + d.footnote + '.');

        //Highlight bar.
        var selection = d3.select(element);
        if (!/trident/i.test(navigator.userAgent)) selection.moveToFront();
        selection.selectAll('.bar').attr('stroke', 'black');
    }

    function select(element, d) {
        var _this = this;

        //Reduce bin opacity and highlight selected bin.
        this.svg
            .selectAll('.bar-group')
            .selectAll('.bar')
            .attr('fill-opacity', 0.5);
        d3.select(element)
            .select('.bar')
            .attr('fill-opacity', 1);

        //Update bar click footnote
        this.footnotes.barClick
            .style({
                cursor: 'pointer',
                'text-decoration': 'underline'
            })
            .text('Click here to remove details and clear highlighting.')
            .on('click', function() {
                resetRenderer.call(_this);
            });

        //Update bar details footnote.
        this.footnotes.barDetails.html('Table displays ' + d.footnote + '.');

        //Draw listing.
        this.listing.draw(d.values.raw);
        this.listing.wrap.style('display', 'inline-block');
    }

    function deselect(element, d) {
        delete this.highlightedBin;
        delete this.highlighteD;
        this.listing.draw([]);
        this.listing.wrap.style('display', 'none');
        this.svg.selectAll('.bar').attr('fill-opacity', 0.75);

        this.footnotes.barClick
            .style({
                cursor: 'normal',
                'text-decoration': 'none'
            })
            .text('Click a bar for details.');
        this.footnotes.barDetails.text(
            d.values.raw.length +
                ' records with ' +
                (this.measure.current + ' values from ') +
                (this.config.x.d3format1(d.rangeLow) +
                    ' to ' +
                    this.config.x.d3format1(d.rangeHigh))
        );
    }

    function click(element, d) {
        this.highlightedBin = d.key;
        this.highlighteD = d;
        var selection = d3.select(element);
        var selected = selection.classed('selected');
        this.svg.selectAll('.bar-group').classed('selected', false);
        selection.classed('selected', !selected);

        if (!selected) select.call(this, element, d);
        else deselect.call(this, element, d);
    }

    function addBinEventListeners() {
        var context = this;

        var barGroups = this.svg.selectAll('.bar-group').style('cursor', 'pointer');

        barGroups
            .on('mouseover', function(d) {
                mouseover.call(context, this, d);
            })
            .on('mouseout', function(d) {
                mouseout.call(context, this, d);
            })
            .on('click', function(d) {
                click.call(context, this, d);
            });
    }

    function drawNormalRanges() {
        var _this = this;

        this.controls.wrap.select('.normal-range-list').remove();
        this.svg.select('.normal-ranges').remove();

        if (this.config.displayNormalRange && this.filtered_data.length > 0) {
            //Capture distinct normal ranges in filtered data.
            var normalRanges = d3
                .nest()
                .key(function(d) {
                    return d[_this.config.normal_col_low] + ',' + d[_this.config.normal_col_high];
                }) // set key to comma-delimited normal range
                .rollup(function(d) {
                    return d.length;
                })
                .entries(this.filtered_data)
                .map(function(d) {
                    d.keySplit = d.key.split(',');

                    //lower
                    d.lower = +d.keySplit[0];
                    d.x1 = d.lower >= _this.x_dom[0] ? _this.x(d.lower) : 0;

                    //upper
                    d.upper = +d.keySplit[1];
                    d.x2 = d.upper <= _this.x_dom[1] ? _this.x(d.upper) : _this.plot_width;

                    //width
                    d.width = d.x2 - d.x1;

                    //tooltip
                    d.rate = d.values / _this.filtered_data.length;
                    d.tooltip =
                        d.values < _this.filtered_data.length
                            ? d.lower +
                              ' - ' +
                              d.upper +
                              ' (' +
                              d3.format('%')(d.rate) +
                              ' of records)'
                            : d.lower + ' - ' + d.upper;

                    //plot if:
                    //  - at least one of the limits of normal fall within the current x-domain
                    //  - the lower limit is less than the current x-domain and the upper limit is greater than current the x-domain
                    d.plot =
                        (_this.x_dom[0] <= d.lower && d.lower <= _this.x_dom[1]) ||
                        (_this.x_dom[0] <= d.upper && d.upper <= _this.x_dom[1]) ||
                        (_this.x_dom[0] >= d.lower && d.upper >= _this.x_dom[1]);

                    return d;
                })
                .sort(function(a, b) {
                    var diff_lower = a.lower - b.lower;
                    var diff_upper = a.upper - b.upper;
                    return diff_lower ? diff_lower : diff_upper ? diff_upper : 0;
                }); // sort normal ranges so larger normal ranges plot beneath smaller normal ranges

            //Add tooltip to Normal Range control that lists normal ranges.
            this.controls.wrap
                .selectAll('#normal-range .wc-control-label')
                .append('span')
                .classed('normal-range-list', true)
                .html(' &#9432')
                .attr(
                    'title',
                    normalRanges.length > 1
                        ? this.measure.current +
                          ' normal ranges:\n' +
                          normalRanges
                              .map(function(normalRange) {
                                  return normalRange.tooltip;
                              })
                              .join('\n')
                        : this.measure.current + ' normal range: ' + normalRanges[0].tooltip
                )
                .style('cursor', 'default');

            //Add groups in which to draw normal range rectangles and annotations.
            var group = this.svg.insert('g', '.bar-supergroup').classed('normal-ranges', true);
            var groups = group
                .selectAll('g.normal-range')
                .data(
                    normalRanges.filter(function(d) {
                        return d.plot;
                    })
                )
                .enter()
                .append('g')
                .classed('normal-range', true);

            //Draw normal range rectangles.
            var rectangles = groups
                .append('rect')
                .classed('normal-range__rect', true)
                .attr({
                    x: function x(d) {
                        return d.x1;
                    },
                    y: 0,
                    width: function width(d) {
                        return d.width;
                    },
                    height: this.plot_height,
                    stroke: '#c26683',
                    fill: '#c26683',
                    'stroke-opacity': function strokeOpacity(d) {
                        return (d.values / _this.filtered_data.length) * 0.5;
                    },
                    'fill-opacity': function fillOpacity(d) {
                        return (d.values / _this.filtered_data.length) * 0.25;
                    }
                }); // opacity as a function of fraction of records with the given normal range
        }
    }

    function maintainBinHighlighting() {
        var _this = this;

        this.svg.selectAll('.bar').attr('fill-opacity', function(d) {
            return _this.highlightedBin
                ? d.key !== _this.highlightedBin
                    ? 0.5
                    : 1
                : _this.marks[0].attributes['fill-opacity'];
        });
    }

    function removeXAxisTicks() {
        if (this.config.annotate_bin_boundaries) this.svg.selectAll('.x.axis .tick').remove();
    }

    function annotateBinBoundaries() {
        var _this = this;

        if (this.config.annotate_bin_boundaries) {
            //Remove bin boundaries.
            this.svg.select('g.bin-boundaries').remove();

            //Check for repeats of values formatted with lower precision.
            var repeats = d3
                .nest()
                .key(function(d) {
                    return d.value1;
                })
                .rollup(function(d) {
                    return d.length;
                })
                .entries(this.measure.binBoundaries)
                .some(function(d) {
                    return d.values > 1;
                });

            //Annotate bin boundaries.
            var axis = this.svg.append('g').classed('bin-boundaries axis', true);
            var ticks = axis
                .selectAll('g.bin-boundary')
                .data(this.measure.binBoundaries)
                .enter()
                .append('g')
                .classed('bin-boundary tick', true);
            var texts = ticks
                .append('text')
                .attr({
                    x: function x(d) {
                        return _this.x(d.value);
                    },
                    y: this.plot_height,
                    dy: '16px',
                    'text-anchor': 'middle'
                })
                .text(function(d) {
                    return repeats ? d.value2 : d.value1;
                });

            //Thin ticks.
            var textDimensions = [];
            texts.each(function(d) {
                var text = d3.select(this);
                var bbox = this.getBBox();
                if (
                    textDimensions.some(function(textDimension) {
                        return textDimension.x + textDimension.width > bbox.x - 5;
                    })
                )
                    text.remove();
                else
                    textDimensions.push({
                        x: bbox.x,
                        width: bbox.width,
                        y: bbox.y,
                        height: bbox.height
                    });
            });
        }
    }

    function onResize() {
        //Draw custom bin for single observation subsets.
        drawZeroRangeBar.call(this);

        //Add invisible bars for improved hovering.
        addHoverBars.call(this);

        //Display data listing on bin click.
        addBinEventListeners.call(this);

        //Visualize normal ranges.
        drawNormalRanges.call(this);

        //Keep highlighted bin highlighted on resize.
        maintainBinHighlighting.call(this);

        //Remove x-axis ticks.
        removeXAxisTicks.call(this);

        //Annotate bin boundaries.
        annotateBinBoundaries.call(this);
    }

    function onDestroy() {
        this.listing.destroy();
        d3.select(this.div)
            .selectAll('.loader')
            .remove();
    }

    var callbacks = {
        onInit: onInit,
        onLayout: onLayout,
        onPreprocess: onPreprocess,
        onDatatransform: onDatatransform,
        onDraw: onDraw,
        onResize: onResize,
        onDestroy: onDestroy
    };

    function safetyHistogram() {
        var element = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'body';
        var settings = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

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
        var controls = webcharts.createControls(element, {
            location: 'top',
            inputs: syncedControlInputs
        });
        var chart = webcharts.createChart(element, syncedSettings, controls);

        //Define chart callbacks.
        for (var callback in callbacks) {
            chart.on(callback.substring(2).toLowerCase(), callbacks[callback]);
        } //Define listing
        var listingSettings = Object.assign(
            {},
            {
                cols: syncedSettings.details.map(function(detail) {
                    return detail.value_col;
                }),
                headers: syncedSettings.details.map(function(detail) {
                    return detail.label;
                })
            },
            syncedSettings
        );
        var listing = webcharts.createTable(element, listingSettings);

        //Attach listing to chart.
        chart.listing = listing;
        listing.chart = chart;

        //Initialize listing and hide initially.
        chart.listing.init([]);
        chart.listing.wrap.style('display', 'none');
        chart.listing.wrap.selectAll('.table-top,table,.table-bottom').style({
            float: 'left',
            clear: 'left',
            width: '100%'
        });

        return chart;
    }

    return safetyHistogram;
});
