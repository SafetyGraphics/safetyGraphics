(function(global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined'
        ? (module.exports = factory(require('d3')))
        : typeof define === 'function' && define.amd
          ? define(['d3'], factory)
          : (global.webCharts = factory(global.d3));
})(typeof self !== 'undefined' ? self : this, function(d3) {
    'use strict';
    var version = '1.11.6';

    function init(data) {
        var _this = this;

        var test = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : false;

        if (d3.select(this.div).select('.loader').empty()) {
            d3
                .select(this.div)
                .insert('div', ':first-child')
                .attr('class', 'loader')
                .selectAll('.blockG')
                .data(d3.range(8))
                .enter()
                .append('div')
                .attr('class', function(d) {
                    return 'blockG rotate' + (d + 1);
                });
        }

        this.wrap.attr('class', 'wc-chart');

        this.setDefaults();

        this.raw_data = data;
        this.initial_data = data;

        var startup = function startup(data) {
            //connect this chart and its controls, if any
            if (_this.controls) {
                _this.controls.targets.push(_this);
                if (!_this.controls.ready) {
                    _this.controls.init(_this.raw_data);
                } else {
                    _this.controls.layout();
                }
            }

            //make sure container is visible (has height and width) before trying to initialize
            var visible = d3.select(_this.div).property('offsetWidth') > 0 || test;
            if (!visible) {
                console.warn(
                    'The chart cannot be initialized inside an element with 0 width. The chart will be initialized as soon as the container element is given a width > 0.'
                );
                var onVisible = setInterval(function(i) {
                    var visible_now = d3.select(_this.div).property('offsetWidth') > 0;
                    if (visible_now) {
                        _this.layout();
                        _this.draw();
                        clearInterval(onVisible);
                    }
                }, 500);
            } else {
                _this.layout();
                _this.draw();
            }
        };

        this.events.onInit.call(this);
        if (this.raw_data.length) {
            this.checkRequired(this.raw_data);
        }
        startup(data);

        return this;
    }

    function checkRequired(data) {
        var _this = this;

        var colnames = Object.keys(data[0]);
        var requiredVars = [];
        var requiredCols = [];
        if (this.config.x && this.config.x.column) {
            requiredVars.push('this.config.x.column');
            requiredCols.push(this.config.x.column);
        }
        if (this.config.y && this.config.y.column) {
            requiredVars.push('this.config.y.column');
            requiredCols.push(this.config.y.column);
        }
        if (this.config.color_by) {
            requiredVars.push('this.config.color_by');
            requiredCols.push(this.config.color_by);
        }
        if (this.config.marks)
            this.config.marks.forEach(function(e, i) {
                if (e.per && e.per.length) {
                    e.per.forEach(function(p, j) {
                        requiredVars.push('this.config.marks[' + i + '].per[' + j + ']');
                        requiredCols.push(p);
                    });
                }
                if (e.split) {
                    requiredVars.push('this.config.marks[' + i + '].split');
                    requiredCols.push(e.split);
                }
                if (e.values) {
                    for (var value in e.values) {
                        requiredVars.push('this.config.marks[' + i + "].values['" + value + "']");
                        requiredCols.push(value);
                    }
                }
            });

        var missingDataField = false;
        requiredCols.forEach(function(e, i) {
            if (colnames.indexOf(e) < 0) {
                missingDataField = true;
                d3.select(_this.div).select('.loader').remove();
                _this.wrap
                    .append('div')
                    .style('color', 'red')
                    .html(
                        'The value "' +
                            e +
                            '" for the <code>' +
                            requiredVars[i] +
                            '</code> setting does not match any column in the provided dataset.'
                    );
                throw new Error(
                    'Error in settings object: The value "' +
                        e +
                        '" for the ' +
                        requiredVars[i] +
                        ' setting does not match any column in the provided dataset.'
                );
            }
        });

        return {
            missingDataField: missingDataField,
            dataFieldArguments: requiredVars,
            requiredDataFields: requiredCols
        };
    }

    function addSVG() {
        this.svg = this.wrap
            .append('svg')
            .datum(function() {
                return null;
            }) // prevent data inheritance
            .attr({
                class: 'wc-svg',
                xmlns: 'http://www.w3.org/2000/svg',
                version: '1.1',
                xlink: 'http://www.w3.org/1999/xlink'
            })
            .append('g')
            .style('display', 'inline-block');
    }

    function addDefs() {
        var defs = this.svg.append('defs');

        //Add pattern.
        defs
            .append('pattern')
            .attr({
                id: 'diagonal-stripes',
                x: 0,
                y: 0,
                width: 3,
                height: 8,
                patternUnits: 'userSpaceOnUse',
                patternTransform: 'rotate(30)'
            })
            .append('rect')
            .attr({
                x: '0',
                y: '0',
                width: '2',
                height: '8'
            })
            .style({
                stroke: 'none',
                fill: 'black'
            });

        //Add clipPath.
        defs.append('clipPath').attr('id', this.id).append('rect').attr('class', 'plotting-area');
    }

    function addXAxis() {
        this.svg
            .append('g')
            .attr('class', 'x axis')
            .append('text')
            .attr('class', 'axis-title')
            .attr('dy', '-.35em')
            .attr('text-anchor', 'middle');
    }

    function addYAxis() {
        this.svg
            .append('g')
            .attr('class', 'y axis')
            .append('text')
            .attr('class', 'axis-title')
            .attr('transform', 'rotate(-90)')
            .attr('dy', '.75em')
            .attr('text-anchor', 'middle');
    }

    function addOverlay() {
        this.overlay = this.svg
            .append('rect')
            .attr('class', 'overlay')
            .attr('opacity', 0)
            .attr('fill', 'none')
            .style('pointer-events', 'all');
    }

    function addLegend() {
        //The legend is contained in the parent object of multiples so each multiple does not need its own legend.
        if (!this.parent)
            this.wrap
                .append('ul')
                .datum(function() {
                    return null;
                }) // prevent data inheritance
                .attr('class', 'legend')
                .style('vertical-align', 'top')
                .append('span')
                .attr('class', 'legend-title');
    }

    function clearLoader() {
        d3.select(this.div).select('.loader').remove();
    }

    function layout() {
        addSVG.call(this);
        addDefs.call(this);
        addXAxis.call(this);
        addYAxis.call(this);
        addOverlay.call(this);
        addLegend.call(this);
        clearLoader.call(this);
        this.events.onLayout.call(this);
    }

    function draw(raw_data, processed_data) {
        var _this = this;

        var chart = this;
        var config = this.config;

        //if pre-processing callback, run it now
        this.events.onPreprocess.call(this);

        /////////////////////////
        // Data prep  pipeline //
        /////////////////////////

        // if user passed raw_data to chart.draw(), use that, otherwise use chart.raw_data
        var raw = raw_data ? raw_data : this.raw_data ? this.raw_data : [];

        // warn the user about the perils of "processed_data"
        if (processed_data) {
            console.warn(
                "Drawing the chart using user-defined 'processed_data', this is an experimental, untested feature."
            );
        }

        //Call consolidateData - this applies filters from controls and prepares data for each set of marks.
        this.consolidateData(raw);

        /////////////////////////////
        // Prepare scales and axes //
        /////////////////////////////

        var div_width = parseInt(this.wrap.style('width'));

        this.setColorScale();

        var max_width = config.max_width ? config.max_width : div_width;
        this.raw_width = config.x.type === 'ordinal' && +config.x.range_band
            ? (+config.x.range_band + config.x.range_band * config.padding) * this.x_dom.length
            : config.resizable ? max_width : config.width ? config.width : div_width;
        this.raw_height = config.y.type === 'ordinal' && +config.y.range_band
            ? (+config.y.range_band + config.y.range_band * config.padding) * this.y_dom.length
            : config.resizable
              ? max_width * (1 / config.aspect)
              : config.height ? config.height : div_width * (1 / config.aspect);

        var pseudo_width = this.svg.select('.overlay').attr('width')
            ? this.svg.select('.overlay').attr('width')
            : this.raw_width;
        var pseudo_height = this.svg.select('.overlay').attr('height')
            ? this.svg.select('.overlay').attr('height')
            : this.raw_height;

        this.svg.select('.x.axis').select('.axis-title').text(function(d) {
            return typeof config.x.label === 'string'
                ? config.x.label
                : typeof config.x.label === 'function' ? config.x.label.call(_this) : null;
        });
        this.svg.select('.y.axis').select('.axis-title').text(function(d) {
            return typeof config.y.label === 'string'
                ? config.y.label
                : typeof config.y.label === 'function' ? config.y.label.call(_this) : null;
        });

        this.xScaleAxis(pseudo_width);
        this.yScaleAxis(pseudo_height);

        if (config.resizable && typeof window !== 'undefined') {
            d3.select(window).on('resize.' + this.element + this.id, function() {
                chart.resize();
            });
        } else if (typeof window !== 'undefined') {
            d3.select(window).on('resize.' + this.element + this.id, null);
        }

        this.events.onDraw.call(this);

        //////////////////////////////////////////////////////////////////////
        // Call resize - updates marks on the chart (amongst other things) //
        /////////////////////////////////////////////////////////////////////
        this.resize();
    }

    function naturalSorter(a, b) {
        //adapted from http://www.davekoelle.com/files/alphanum.js
        function chunkify(t) {
            var tz = [];
            var x = 0,
                y = -1,
                n = 0,
                i = void 0,
                j = void 0;

            while ((i = (j = t.charAt(x++)).charCodeAt(0))) {
                var m = i == 46 || (i >= 48 && i <= 57);
                if (m !== n) {
                    tz[++y] = '';
                    n = m;
                }
                tz[y] += j;
            }
            return tz;
        }

        var aa = chunkify(a.toLowerCase());
        var bb = chunkify(b.toLowerCase());

        for (var x = 0; aa[x] && bb[x]; x++) {
            if (aa[x] !== bb[x]) {
                var c = Number(aa[x]),
                    d = Number(bb[x]);
                if (c == aa[x] && d == bb[x]) {
                    return c - d;
                } else {
                    return aa[x] > bb[x] ? 1 : -1;
                }
            }
        }

        return aa.length - bb.length;
    }

    function setDomain(axis) {
        var _this = this;

        var otherAxis = axis === 'x' ? 'y' : 'x';

        if (this.config[axis].type === 'ordinal') {
            //ordinal domains
            if (this.config[axis].domain) {
                //user-defined domain
                this[axis + '_dom'] = this.config[axis].domain;
            } else if (this.config[axis].order) {
                //data-driven domain with user-defined domain order
                this[axis + '_dom'] = d3
                    .set(
                        d3.merge(
                            this.marks.map(function(mark) {
                                return mark[axis + '_dom'];
                            })
                        )
                    )
                    .values()
                    .sort(function(a, b) {
                        return d3.ascending(
                            _this.config[axis].order.indexOf(a),
                            _this.config[axis].order.indexOf(b)
                        );
                    });
            } else if (
                this.config[axis].sort &&
                this.config[axis].sort === 'alphabetical-ascending'
            ) {
                //data-driven domain with user-defined domain sort algorithm that sorts the axis
                //alphanumerically, first to last
                this[axis + '_dom'] = d3
                    .set(
                        d3.merge(
                            this.marks.map(function(mark) {
                                return mark[axis + '_dom'];
                            })
                        )
                    )
                    .values()
                    .sort(naturalSorter);
            } else if (
                ['time', 'linear'].indexOf(this.config[otherAxis].type) > -1 &&
                this.config[axis].sort === 'earliest'
            ) {
                //data-driven domain plotted against a time or linear axis that sorts the axis values
                //by earliest event/datum; generally used with timeline charts
                this[axis + '_dom'] = d3
                    .nest()
                    .key(function(d) {
                        return d[_this.config[axis].column];
                    })
                    .rollup(function(d) {
                        return d
                            .map(function(m) {
                                return m[_this.config[otherAxis].column];
                            })
                            .filter(function(f) {
                                return f instanceof Date;
                            });
                    })
                    .entries(this.filtered_data)
                    .sort(function(a, b) {
                        return d3.min(b.values) - d3.min(a.values);
                    })
                    .map(function(m) {
                        return m.key;
                    });
            } else if (
                !this.config[axis].sort ||
                this.config[axis].sort === 'alphabetical-descending'
            ) {
                //data-driven domain with default/user-defined domain sort algorithm that sorts the
                //axis alphanumerically, last to first
                this[axis + '_dom'] = d3
                    .set(
                        d3.merge(
                            this.marks.map(function(mark) {
                                return mark[axis + '_dom'];
                            })
                        )
                    )
                    .values()
                    .sort(naturalSorter)
                    .reverse();
            } else {
                //data-driven domain with an invalid user-defined sort algorithm that captures a unique
                //set of values as they appear in the data
                this[axis + '_dom'] = d3
                    .set(
                        d3.merge(
                            this.marks.map(function(mark) {
                                return mark[axis + '_dom'];
                            })
                        )
                    )
                    .values();
            }
        } else if (
            this.config.marks
                .map(function(m) {
                    return m['summarize' + axis.toUpperCase()] === 'percent';
                })
                .indexOf(true) > -1
        ) {
            //rate domains run from 0 to 1
            this[axis + '_dom'] = [0, 1];
        } else {
            //continuous domains run from the minimum to the maximum raw (or is it summarized...?) value
            //TODO: they should really run from the minimum to the maximum summarized value, e.g. a
            //TODO: means over time chart should plot over the range of the means, not the range of the
            //TODO: raw data
            this[axis + '_dom'] = d3.extent(
                d3.merge(
                    this.marks.map(function(mark) {
                        return mark[axis + '_dom'];
                    })
                )
            );
        }

        //Give the domain a range when the range of the variable is 0.
        if (
            this.config[axis].type === 'linear' &&
            this[axis + '_dom'][0] === this[axis + '_dom'][1]
        )
            this[axis + '_dom'] = this[axis + '_dom'][0] !== 0
                ? [
                      this[axis + '_dom'][0] - this[axis + '_dom'][0] * 0.01,
                      this[axis + '_dom'][1] + this[axis + '_dom'][1] * 0.01
                  ]
                : [-1, 1];

        return this[axis + '_dom'];
    }

    function consolidateData(raw) {
        var _this = this;

        this.setDefaults();

        //Apply filters from associated controls objects to raw data.
        this.filtered_data = raw;
        if (this.filters.length) {
            this.filters.forEach(function(filter) {
                _this.filtered_data = _this.filtered_data.filter(function(d) {
                    return filter.all === true && filter.index === 0
                        ? d
                        : filter.val instanceof Array
                          ? filter.val.indexOf(d[filter.col]) > -1
                          : d[filter.col] === filter.val;
                });
            });
        }

        //Summarize data for each mark.
        this.config.marks.forEach(function(mark, i) {
            if (mark.type !== 'bar') {
                mark.arrange = null;
                mark.split = null;
            }

            var mark_info = mark.per
                ? _this.transformData(raw, mark)
                : {
                      data: [],
                      x_dom: [],
                      y_dom: []
                  };

            _this.marks[i] = Object.assign({}, mark, mark_info);
        });

        //Set domains given extents of summarized mark data.
        setDomain.call(this, 'x');
        setDomain.call(this, 'y');
    }

    function setDefaults() {
        this.config.x = this.config.x || {};
        this.config.y = this.config.y || {};

        this.config.x.label = this.config.x.label !== undefined
            ? this.config.x.label
            : this.config.x.column;
        this.config.y.label = this.config.y.label !== undefined
            ? this.config.y.label
            : this.config.y.column;

        this.config.x.sort = this.config.x.sort || 'alphabetical-ascending';
        this.config.y.sort = this.config.y.sort || 'alphabetical-descending';

        this.config.x.type = this.config.x.type || 'linear';
        this.config.y.type = this.config.y.type || 'linear';

        this.config.x.range_band = this.config.x.range_band || this.config.range_band;
        this.config.y.range_band = this.config.y.range_band || this.config.range_band;

        this.config.margin = this.config.margin || {};
        this.config.legend = this.config.legend || {};
        this.config.legend.label = this.config.legend.label !== undefined
            ? this.config.legend.label
            : this.config.color_by;
        this.config.legend.location = this.config.legend.location !== undefined
            ? this.config.legend.location
            : 'bottom';
        this.config.marks = this.config.marks && this.config.marks.length
            ? this.config.marks
            : [{}];
        this.config.marks.forEach(function(m, i) {
            m.id = m.id ? m.id : 'mark' + (i + 1);
        });

        this.config.date_format = this.config.date_format || '%x';

        this.config.padding = this.config.padding !== undefined ? this.config.padding : 0.3;
        this.config.outer_pad = this.config.outer_pad !== undefined ? this.config.outer_pad : 0.1;

        this.config.resizable = this.config.resizable !== undefined ? this.config.resizable : true;

        this.config.aspect = this.config.aspect || 1.33;

        this.config.colors = this.config.colors || [
            'rgb(102,194,165)',
            'rgb(252,141,98)',
            'rgb(141,160,203)',
            'rgb(231,138,195)',
            'rgb(166,216,84)',
            'rgb(255,217,47)',
            'rgb(229,196,148)',
            'rgb(179,179,179)'
        ];

        this.config.scale_text = this.config.scale_text === undefined
            ? true
            : this.config.scale_text;
        this.config.transitions = this.config.transitions === undefined
            ? true
            : this.config.transitions;
    }

    function cleanData(mark, raw) {
        var _this = this;

        var dateConvert = d3.time.format(this.config.date_format);
        var clean = raw;
        // only use data for the current mark
        clean = mark.per && mark.per.length
            ? clean.filter(function(f) {
                  return f[mark.per[0]] !== undefined;
              })
            : clean;

        // Make sure data has x and y values
        if (this.config.x.column) {
            clean = clean.filter(function(f) {
                return [undefined, null].indexOf(f[_this.config.x.column]) < 0;
            });
        }
        if (this.config.y.column) {
            clean = clean.filter(function(f) {
                return [undefined, null].indexOf(f[_this.config.y.column]) < 0;
            });
        }

        //check that x and y have the correct formats
        if (this.config.x.type === 'time') {
            clean = clean.filter(function(f) {
                return f[_this.config.x.column] instanceof Date
                    ? f[_this.config.x.column]
                    : dateConvert.parse(f[_this.config.x.column]);
            });
            clean.forEach(function(e) {
                return (e[_this.config.x.column] = e[_this.config.x.column] instanceof Date
                    ? e[_this.config.x.column]
                    : dateConvert.parse(e[_this.config.x.column]));
            });
        }
        if (this.config.y.type === 'time') {
            clean = clean.filter(function(f) {
                return f[_this.config.y.column] instanceof Date
                    ? f[_this.config.y.column]
                    : dateConvert.parse(f[_this.config.y.column]);
            });
            clean.forEach(function(e) {
                return (e[_this.config.y.column] = e[_this.config.y.column] instanceof Date
                    ? e[_this.config.y.column]
                    : dateConvert.parse(e[_this.config.y.column]));
            });
        }

        if (
            (this.config.x.type === 'linear' || this.config.x.type === 'log') &&
            this.config.x.column
        ) {
            clean = clean.filter(function(f) {
                return mark.summarizeX !== 'count' && mark.summarizeX !== 'percent'
                    ? !(isNaN(f[_this.config.x.column]) || /^\s*$/.test(f[_this.config.x.column])) // is or coerces to a number and is not a string that coerces to 0
                    : f;
            });
        }
        if (
            (this.config.y.type === 'linear' || this.config.y.type === 'log') &&
            this.config.y.column
        ) {
            clean = clean.filter(function(f) {
                return mark.summarizeY !== 'count' && mark.summarizeY !== 'percent'
                    ? !(isNaN(f[_this.config.y.column]) || /^\s*$/.test(f[_this.config.y.column])) // is or coerces to a number and is not a string that coerces to 0
                    : f;
            });
        }

        return clean;
    }

    var stats = {
        mean: d3.mean,
        min: d3.min,
        max: d3.max,
        median: d3.median,
        sum: d3.sum
    };

    function summarize(vals) {
        var operation = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 'mean';

        var nvals = vals
            .filter(function(f) {
                return +f || +f === 0;
            })
            .map(function(m) {
                return +m;
            });

        if (operation === 'cumulative') {
            return null;
        }

        var mathed = operation === 'count'
            ? vals.length
            : operation === 'percent' ? vals.length : stats[operation](nvals);

        return mathed;
    }

    function makeNest(mark, entries, sublevel) {
        var _this = this;

        var dom_xs = [];
        var dom_ys = [];
        var this_nest = d3.nest();
        var totalOrder = void 0;

        if (
            (this.config.x.type === 'linear' && this.config.x.bin) ||
            (this.config.y.type === 'linear' && this.config.y.bin)
        ) {
            var xy = this.config.x.type === 'linear' && this.config.x.bin ? 'x' : 'y';
            mark.quant = d3.scale
                .quantile()
                .domain(
                    this.config[xy].domain
                        ? this.config[xy].domain
                        : d3.extent(
                              entries.map(function(m) {
                                  return +m[_this.config[xy].column];
                              })
                          )
                )
                .range(d3.range(+this.config[xy].bin));

            entries.forEach(function(e) {
                return (e.wc_bin = mark.quant(e[_this.config[xy].column]));
            });

            this_nest.key(function(d) {
                return mark.quant.invertExtent(d.wc_bin);
            });
        } else {
            this_nest.key(function(d) {
                return mark.per
                    .map(function(m) {
                        return d[m];
                    })
                    .join(' ');
            });
        }

        if (sublevel) {
            this_nest.key(function(d) {
                return d[sublevel];
            });
            this_nest.sortKeys(function(a, b) {
                return _this.config.x.type === 'time'
                    ? d3.ascending(new Date(a), new Date(b))
                    : _this.config.x.order
                      ? d3.ascending(
                            _this.config.x.order.indexOf(a),
                            _this.config.x.order.indexOf(b)
                        )
                      : sublevel === _this.config.color_by && _this.config.legend.order
                        ? d3.ascending(
                              _this.config.legend.order.indexOf(a),
                              _this.config.legend.order.indexOf(b)
                          )
                        : _this.config.x.type === 'ordinal' || _this.config.y.type === 'ordinal'
                          ? naturalSorter(a, b)
                          : d3.ascending(+a, +b);
            });
        }
        this_nest.rollup(function(r) {
            var obj = { raw: r };
            var y_vals = r
                .map(function(m) {
                    return m[_this.config.y.column];
                })
                .sort(d3.ascending);
            var x_vals = r
                .map(function(m) {
                    return m[_this.config.x.column];
                })
                .sort(d3.ascending);
            obj.x = _this.config.x.type === 'ordinal'
                ? r[0][_this.config.x.column]
                : summarize(x_vals, mark.summarizeX);
            obj.y = _this.config.y.type === 'ordinal'
                ? r[0][_this.config.y.column]
                : summarize(y_vals, mark.summarizeY);

            obj.x_q25 = _this.config.error_bars && _this.config.y.type === 'ordinal'
                ? d3.quantile(x_vals, 0.25)
                : obj.x;
            obj.x_q75 = _this.config.error_bars && _this.config.y.type === 'ordinal'
                ? d3.quantile(x_vals, 0.75)
                : obj.x;
            obj.y_q25 = _this.config.error_bars ? d3.quantile(y_vals, 0.25) : obj.y;
            obj.y_q75 = _this.config.error_bars ? d3.quantile(y_vals, 0.75) : obj.y;
            dom_xs.push([obj.x_q25, obj.x_q75, obj.x]);
            dom_ys.push([obj.y_q25, obj.y_q75, obj.y]);

            if (mark.summarizeY === 'cumulative') {
                var interm = entries.filter(function(f) {
                    return _this.config.x.type === 'time'
                        ? new Date(f[_this.config.x.column]) <=
                              new Date(r[0][_this.config.x.column])
                        : +f[_this.config.x.column] <= +r[0][_this.config.x.column];
                });
                if (mark.per.length) {
                    interm = interm.filter(function(f) {
                        return f[mark.per[0]] === r[0][mark.per[0]];
                    });
                }

                var cumul = _this.config.x.type === 'time'
                    ? interm.length
                    : d3.sum(
                          interm.map(function(m) {
                              return +m[_this.config.y.column] || +m[_this.config.y.column] === 0
                                  ? +m[_this.config.y.column]
                                  : 1;
                          })
                      );
                dom_ys.push([cumul]);
                obj.y = cumul;
            }
            if (mark.summarizeX === 'cumulative') {
                var _interm = entries.filter(function(f) {
                    return _this.config.y.type === 'time'
                        ? new Date(f[_this.config.y.column]) <=
                              new Date(r[0][_this.config.y.column])
                        : +f[_this.config.y.column] <= +r[0][_this.config.y.column];
                });
                if (mark.per.length) {
                    _interm = _interm.filter(function(f) {
                        return f[mark.per[0]] === r[0][mark.per[0]];
                    });
                }
                dom_xs.push([_interm.length]);
                obj.x = _interm.length;
            }

            return obj;
        });

        var test = this_nest.entries(entries);

        var dom_x = d3.extent(d3.merge(dom_xs));
        var dom_y = d3.extent(d3.merge(dom_ys));

        if (sublevel && mark.type === 'bar' && mark.split) {
            //calculate percentages in bars
            test.forEach(function(e) {
                var axis = _this.config.x.type === 'ordinal' ||
                    (_this.config.x.type === 'linear' && _this.config.x.bin)
                    ? 'y'
                    : 'x';
                e.total = d3.sum(
                    e.values.map(function(m) {
                        return +m.values[axis];
                    })
                );
                var counter = 0;
                e.values.forEach(function(v, i) {
                    if (
                        _this.config.x.type === 'ordinal' ||
                        (_this.config.x.type === 'linear' && _this.config.x.bin)
                    ) {
                        v.values.y = mark.summarizeY === 'percent'
                            ? v.values.y / e.total
                            : v.values.y || 0;
                        counter += +v.values.y;
                        v.values.start = e.values[i - 1] ? counter : v.values.y;
                    } else {
                        v.values.x = mark.summarizeX === 'percent'
                            ? v.values.x / e.total
                            : v.values.x || 0;
                        v.values.start = counter;
                        counter += +v.values.x;
                    }
                });
            });

            if (mark.arrange === 'stacked') {
                if (
                    this.config.x.type === 'ordinal' ||
                    (this.config.x.type === 'linear' && this.config.x.bin)
                ) {
                    dom_y = d3.extent(
                        test.map(function(m) {
                            return m.total;
                        })
                    );
                }
                if (
                    this.config.y.type === 'ordinal' ||
                    (this.config.y.type === 'linear' && this.config.y.bin)
                ) {
                    dom_x = d3.extent(
                        test.map(function(m) {
                            return m.total;
                        })
                    );
                }
            }
        } else {
            var axis = this.config.x.type === 'ordinal' ||
                (this.config.x.type === 'linear' && this.config.x.bin)
                ? 'y'
                : 'x';
            test.forEach(function(e) {
                return (e.total = e.values[axis]);
            });
        }

        if (
            (this.config.x.sort === 'total-ascending' && this.config.x.type == 'ordinal') ||
            (this.config.y.sort === 'total-descending' && this.config.y.type == 'ordinal')
        ) {
            totalOrder = test
                .sort(function(a, b) {
                    return d3.ascending(a.total, b.total);
                })
                .map(function(m) {
                    return m.key;
                });
        } else if (
            (this.config.x.sort === 'total-descending' && this.config.x.type == 'ordinal') ||
            (this.config.y.sort === 'total-ascending' && this.config.y.type == 'ordinal')
        ) {
            totalOrder = test
                .sort(function(a, b) {
                    return d3.descending(+a.total, +b.total);
                })
                .map(function(m) {
                    return m.key;
                });
        }

        return { nested: test, dom_x: dom_x, dom_y: dom_y, totalOrder: totalOrder };
    }

    //////////////////////////////////////////////////////////
    // transformData(raw, mark) provides specifications and data for
    // each set of marks. As such, it is called once for each
    // item specified in the config.marks array.
    //
    // parameters
    // raw - the raw data for use in the mark. Filters from controls
    //       are typically already applied.
    // mark - a single mark object from config.marks
    ////////////////////////////////////////////////////////

    function transformData(raw, mark) {
        var _this = this;

        //convenience mappings
        var config = this.config;
        var x_behavior = config.x.behavior || 'raw';
        var y_behavior = config.y.behavior || 'raw';
        var sublevel = mark.type === 'line'
            ? config.x.column
            : mark.type === 'bar' && mark.split ? mark.split : null;

        //////////////////////////////////////////////////////////////////////////////////
        // DATA PREP
        // prepare data based on the properties of the mark - drop missing records, etc
        //////////////////////////////////////////////////////////////////////////////////
        var cleaned = cleanData.call(this, mark, raw);

        //prepare nested data required for bar charts
        var raw_nest = void 0;
        if (mark.type === 'bar') {
            raw_nest = mark.arrange !== 'stacked'
                ? makeNest.call(this, mark, cleaned, sublevel)
                : makeNest.call(this, mark, cleaned);
        } else if (mark.summarizeX === 'count' || mark.summarizeY === 'count') {
            raw_nest = makeNest.call(this, mark, cleaned);
        }

        // Get the domain for the mark based on the raw data
        var raw_dom_x = mark.summarizeX === 'cumulative'
            ? [0, cleaned.length]
            : config.x.type === 'ordinal'
              ? d3
                    .set(
                        cleaned.map(function(m) {
                            return m[config.x.column];
                        })
                    )
                    .values()
                    .filter(function(f) {
                        return f;
                    })
              : mark.split && mark.arrange !== 'stacked'
                ? d3.extent(
                      d3.merge(
                          raw_nest.nested.map(function(m) {
                              return m.values.map(function(p) {
                                  return p.values.raw.length;
                              });
                          })
                      )
                  )
                : mark.summarizeX === 'count'
                  ? d3.extent(
                        raw_nest.nested.map(function(m) {
                            return m.values.raw.length;
                        })
                    )
                  : d3.extent(
                        cleaned
                            .map(function(m) {
                                return +m[config.x.column];
                            })
                            .filter(function(f) {
                                return +f || +f === 0;
                            })
                    );

        var raw_dom_y = mark.summarizeY === 'cumulative'
            ? [0, cleaned.length]
            : config.y.type === 'ordinal'
              ? d3
                    .set(
                        cleaned.map(function(m) {
                            return m[config.y.column];
                        })
                    )
                    .values()
                    .filter(function(f) {
                        return f;
                    })
              : mark.split && mark.arrange !== 'stacked'
                ? d3.extent(
                      d3.merge(
                          raw_nest.nested.map(function(m) {
                              return m.values.map(function(p) {
                                  return p.values.raw.length;
                              });
                          })
                      )
                  )
                : mark.summarizeY === 'count'
                  ? d3.extent(
                        raw_nest.nested.map(function(m) {
                            return m.values.raw.length;
                        })
                    )
                  : d3.extent(
                        cleaned
                            .map(function(m) {
                                return +m[config.y.column];
                            })
                            .filter(function(f) {
                                return +f || +f === 0;
                            })
                    );

        var filtered = cleaned;

        var filt1_xs = [];
        var filt1_ys = [];
        if (this.filters.length) {
            this.filters.forEach(function(e) {
                filtered = filtered.filter(function(d) {
                    return e.all === true && e.index === 0
                        ? d
                        : e.val instanceof Array
                          ? e.val.indexOf(d[e.col]) > -1
                          : d[e.col] === e.val;
                });
            });
            //get domain for all non-All values of first filter
            if (config.x.behavior === 'firstfilter' || config.y.behavior === 'firstfilter') {
                this.filters[0].choices
                    .filter(function(f) {
                        return f !== 'All';
                    })
                    .forEach(function(e) {
                        var perfilter = cleaned.filter(function(f) {
                            return f[_this.filters[0].col] === e;
                        });
                        var filt_nested = makeNest.call(_this, mark, perfilter, sublevel);
                        filt1_xs.push(filt_nested.dom_x);
                        filt1_ys.push(filt_nested.dom_y);
                    });
            }
        }

        //filter on mark-specific instructions
        if (mark.values) {
            var _loop = function _loop(a) {
                filtered = filtered.filter(function(f) {
                    return mark.values[a].indexOf(f[a]) > -1;
                });
            };

            for (var a in mark.values) {
                _loop(a);
            }
        }
        var filt1_dom_x = d3.extent(d3.merge(filt1_xs));
        var filt1_dom_y = d3.extent(d3.merge(filt1_ys));

        var current_nested = makeNest.call(this, mark, filtered, sublevel);

        var flex_dom_x = current_nested.dom_x;
        var flex_dom_y = current_nested.dom_y;

        if (mark.type === 'bar') {
            if (config.y.type === 'ordinal' && mark.summarizeX === 'count') {
                config.x.domain = config.x.domain ? [0, config.x.domain[1]] : [0, null];
            } else if (config.x.type === 'ordinal' && mark.summarizeY === 'count') {
                config.y.domain = config.y.domain ? [0, config.y.domain[1]] : [0, null];
            }
        }

        //several criteria must be met in order to use the 'firstfilter' domain
        var nonall = Boolean(
            this.filters.length &&
                this.filters[0].val !== 'All' &&
                this.filters.slice(1).filter(function(f) {
                    return f.val === 'All';
                }).length ===
                    this.filters.length - 1
        );

        var pre_x_dom = !this.filters.length
            ? flex_dom_x
            : x_behavior === 'raw'
              ? raw_dom_x
              : nonall && x_behavior === 'firstfilter' ? filt1_dom_x : flex_dom_x;
        var pre_y_dom = !this.filters.length
            ? flex_dom_y
            : y_behavior === 'raw'
              ? raw_dom_y
              : nonall && y_behavior === 'firstfilter' ? filt1_dom_y : flex_dom_y;

        var x_dom = config.x_dom
            ? config.x_dom
            : config.x.type === 'ordinal' && config.x.behavior === 'flex'
              ? d3
                    .set(
                        filtered.map(function(m) {
                            return m[config.x.column];
                        })
                    )
                    .values()
              : config.x.type === 'ordinal'
                ? d3
                      .set(
                          cleaned.map(function(m) {
                              return m[config.x.column];
                          })
                      )
                      .values()
                : pre_x_dom;

        var y_dom = config.y_dom
            ? config.y_dom
            : config.y.type === 'ordinal' && config.y.behavior === 'flex'
              ? d3
                    .set(
                        filtered.map(function(m) {
                            return m[config.y.column];
                        })
                    )
                    .values()
              : config.y.type === 'ordinal'
                ? d3
                      .set(
                          cleaned.map(function(m) {
                              return m[config.y.column];
                          })
                      )
                      .values()
                : pre_y_dom;

        //set lower limit of linear domain to 0 when other axis is ordinal and mark type is set to 'bar', provided no values are negative
        if (mark.type === 'bar') {
            if (
                config.x.behavior !== 'flex' &&
                config.x.type === 'linear' &&
                config.y.type === 'ordinal' &&
                raw_dom_x[0] >= 0
            )
                x_dom[0] = 0;

            if (
                config.y.behavior !== 'flex' &&
                config.x.type === 'ordinal' &&
                config.y.type === 'linear' &&
                raw_dom_y[0] >= 0
            )
                y_dom[0] = 0;
        }

        //update domains with those specified in the config
        if (
            config.x.domain &&
            (config.x.domain[0] || config.x.domain[0] === 0) &&
            !isNaN(+config.x.domain[0])
        ) {
            x_dom[0] = config.x.domain[0];
        }
        if (
            config.x.domain &&
            (config.x.domain[1] || config.x.domain[1] === 0) &&
            !isNaN(+config.x.domain[1])
        ) {
            x_dom[1] = config.x.domain[1];
        }
        if (
            config.y.domain &&
            (config.y.domain[0] || config.y.domain[0] === 0) &&
            !isNaN(+config.y.domain[0])
        ) {
            y_dom[0] = config.y.domain[0];
        }
        if (
            config.y.domain &&
            (config.y.domain[1] || config.y.domain[1] === 0) &&
            !isNaN(+config.y.domain[1])
        ) {
            y_dom[1] = config.y.domain[1];
        }

        if (config.x.type === 'ordinal' && !config.x.order) {
            config.x.order = current_nested.totalOrder;
        }
        if (config.y.type === 'ordinal' && !config.y.order) {
            config.y.order = current_nested.totalOrder;
        }

        this.current_data = current_nested.nested;

        this.events.onDatatransform.call(this);

        return { config: mark, data: current_nested.nested, x_dom: x_dom, y_dom: y_dom };
    }

    function setColorScale() {
        var config = this.config;
        var data = config.legend.behavior === 'flex' ? this.filtered_data : this.raw_data;
        var colordom = Array.isArray(config.color_dom) && config.color_dom.length
            ? config.color_dom.slice()
            : d3
                  .set(
                      data.map(function(m) {
                          return m[config.color_by];
                      })
                  )
                  .values()
                  .filter(function(f) {
                      return f && f !== 'undefined';
                  });

        if (config.legend.order)
            colordom.sort(function(a, b) {
                return d3.ascending(config.legend.order.indexOf(a), config.legend.order.indexOf(b));
            });
        else colordom.sort(naturalSorter);

        this.colorScale = d3.scale.ordinal().domain(colordom).range(config.colors);
    }

    function xScaleAxis(max_range, domain, type) {
        if (max_range === undefined) {
            max_range = this.plot_width;
        }
        if (domain === undefined) {
            domain = this.x_dom;
        }
        if (type === undefined) {
            type = this.config.x.type;
        }
        var config = this.config;
        var x = void 0;

        if (type === 'log') {
            x = d3.scale.log();
        } else if (type === 'ordinal') {
            x = d3.scale.ordinal();
        } else if (type === 'time') {
            x = d3.time.scale();
        } else {
            x = d3.scale.linear();
        }

        x.domain(domain);

        if (type === 'ordinal') {
            x.rangeBands([0, +max_range], config.padding, config.outer_pad);
        } else {
            x.range([0, +max_range]).clamp(Boolean(config.x.clamp));
        }

        var xFormat = config.x.format
            ? config.x.format
            : config.marks
                  .map(function(m) {
                      return m.summarizeX === 'percent';
                  })
                  .indexOf(true) > -1
              ? '0%'
              : type === 'time' ? '%x' : '.0f';
        var tick_count = Math.max(2, Math.min(max_range / 80, 8));
        var xAxis = d3.svg
            .axis()
            .scale(x)
            .orient(config.x.location)
            .ticks(tick_count)
            .tickFormat(
                type === 'ordinal'
                    ? null
                    : type === 'time' ? d3.time.format(xFormat) : d3.format(xFormat)
            )
            .tickValues(config.x.ticks ? config.x.ticks : null)
            .innerTickSize(6)
            .outerTickSize(3);

        this.svg.select('g.x.axis').attr('class', 'x axis ' + type);
        this.x = x;
        this.xAxis = xAxis;
    }

    function yScaleAxis(max_range, domain, type) {
        if (max_range === undefined) {
            max_range = this.plot_height;
        }
        if (domain === undefined) {
            domain = this.y_dom;
        }
        if (type === undefined) {
            type = this.config.y.type;
        }
        var config = this.config;
        var y = void 0;
        if (type === 'log') {
            y = d3.scale.log();
        } else if (type === 'ordinal') {
            y = d3.scale.ordinal();
        } else if (type === 'time') {
            y = d3.time.scale();
        } else {
            y = d3.scale.linear();
        }

        y.domain(domain);

        if (type === 'ordinal') {
            y.rangeBands([+max_range, 0], config.padding, config.outer_pad);
        } else {
            y.range([+max_range, 0]).clamp(Boolean(config.y_clamp));
        }

        var yFormat = config.y.format
            ? config.y.format
            : config.marks
                  .map(function(m) {
                      return m.summarizeY === 'percent';
                  })
                  .indexOf(true) > -1
              ? '0%'
              : '.0f';
        var tick_count = Math.max(2, Math.min(max_range / 80, 8));
        var yAxis = d3.svg
            .axis()
            .scale(y)
            .orient('left')
            .ticks(tick_count)
            .tickFormat(
                type === 'ordinal'
                    ? null
                    : type === 'time' ? d3.time.format(yFormat) : d3.format(yFormat)
            )
            .tickValues(config.y.ticks ? config.y.ticks : null)
            .innerTickSize(6)
            .outerTickSize(3);

        this.svg.select('g.y.axis').attr('class', 'y axis ' + type);

        this.y = y;
        this.yAxis = yAxis;
    }

    function resize() {
        var config = this.config;

        var aspect2 = 1 / config.aspect;
        var div_width = parseInt(this.wrap.style('width'));
        var max_width = config.max_width ? config.max_width : div_width;
        var preWidth = !config.resizable
            ? config.width
            : !max_width || div_width < max_width ? div_width : this.raw_width;

        this.textSize(preWidth);

        this.margin = this.setMargins();

        var svg_width = config.x.type === 'ordinal' && +config.x.range_band
            ? this.raw_width + this.margin.left + this.margin.right
            : !config.resizable
              ? this.raw_width
              : !config.max_width || div_width < config.max_width ? div_width : this.raw_width;
        this.plot_width = svg_width - this.margin.left - this.margin.right;
        var svg_height = config.y.type === 'ordinal' && +config.y.range_band
            ? this.raw_height + this.margin.top + this.margin.bottom
            : !config.resizable && config.height
              ? config.height
              : !config.resizable ? svg_width * aspect2 : this.plot_width * aspect2;
        this.plot_height = svg_height - this.margin.top - this.margin.bottom;

        d3
            .select(this.svg.node().parentNode)
            .attr('width', svg_width)
            .attr('height', svg_height)
            .select('g')
            .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

        this.svg
            .select('.overlay')
            .attr('width', this.plot_width)
            .attr('height', this.plot_height)
            .classed('zoomable', config.zoomable);

        this.svg
            .select('.plotting-area')
            .attr('width', this.plot_width)
            .attr('height', this.plot_height + 1)
            .attr('transform', 'translate(0, -1)');

        this.xScaleAxis();
        this.yScaleAxis();

        var g_x_axis = this.svg.select('.x.axis');
        var g_y_axis = this.svg.select('.y.axis');
        var x_axis_label = g_x_axis.select('.axis-title');
        var y_axis_label = g_y_axis.select('.axis-title');

        if (config.x_location !== 'top') {
            g_x_axis.attr('transform', 'translate(0,' + this.plot_height + ')');
        }
        var gXAxisTrans = config.transitions ? g_x_axis.transition() : g_x_axis;
        gXAxisTrans.call(this.xAxis);
        var gYAxisTrans = config.transitions ? g_y_axis.transition() : g_y_axis;
        gYAxisTrans.call(this.yAxis);

        x_axis_label.attr(
            'transform',
            'translate(' + this.plot_width / 2 + ',' + (this.margin.bottom - 2) + ')'
        );
        y_axis_label.attr('x', -1 * this.plot_height / 2).attr('y', -1 * this.margin.left);

        this.svg
            .selectAll('.axis .domain')
            .attr({
                fill: 'none',
                stroke: '#ccc',
                'stroke-width': 1,
                'shape-rendering': 'crispEdges'
            });
        this.svg
            .selectAll('.axis .tick line')
            .attr({ stroke: '#eee', 'stroke-width': 1, 'shape-rendering': 'crispEdges' });

        this.drawGridlines();

        //update legend - margins need to be set first
        this.makeLegend();

        //update the chart's specific marks
        this.updateDataMarks();

        //call .on("resize") function, if any
        this.events.onResize.call(this);
    }

    function textSize(width) {
        var font_size = '14px';
        var point_size = 4;
        var stroke_width = 2;

        if (!this.config.scale_text) {
            font_size = this.config.font_size;
            point_size = this.config.point_size || 4;
            stroke_width = this.config.stroke_width || 2;
        } else if (width >= 600) {
            font_size = '14px';
            point_size = 4;
            stroke_width = 2;
        } else if (width > 450 && width < 600) {
            font_size = '12px';
            point_size = 3;
            stroke_width = 2;
        } else if (width > 300 && width < 450) {
            font_size = '10px';
            point_size = 2;
            stroke_width = 2;
        } else if (width <= 300) {
            font_size = '10px';
            point_size = 2;
            stroke_width = 1;
        }

        this.wrap.style('font-size', font_size);
        this.config.flex_point_size = point_size;
        this.config.flex_stroke_width = stroke_width;
    }

    function setMargins() {
        var _this = this;

        var y_ticks = this.yAxis.tickFormat()
            ? this.y.domain().map(function(m) {
                  return _this.yAxis.tickFormat()(m);
              })
            : this.y.domain();

        var max_y_text_length = d3.max(
            y_ticks.map(function(m) {
                return String(m).length;
            })
        );
        if (this.config.y_format && this.config.y_format.indexOf('%') > -1) {
            max_y_text_length += 1;
        }
        max_y_text_length = Math.max(2, max_y_text_length);
        var x_label_on = this.config.x.label ? 1.5 : 0;
        var y_label_on = this.config.y.label ? 1.5 : 0.25;
        var font_size = parseInt(this.wrap.style('font-size'));
        var x_second = this.config.x2_interval ? 1 : 0;
        var y_margin = max_y_text_length * font_size * 0.5 + font_size * y_label_on * 1.5 || 8;
        var x_margin =
            font_size + font_size / 1.5 + font_size * x_label_on + font_size * x_second || 8;

        y_margin += 6;
        x_margin += 3;

        return {
            top: this.config.margin && this.config.margin.top ? this.config.margin.top : 8,
            right: this.config.margin && this.config.margin.right ? this.config.margin.right : 16,
            bottom: this.config.margin && this.config.margin.bottom
                ? this.config.margin.bottom
                : x_margin,
            left: this.config.margin && this.config.margin.left ? this.config.margin.left : y_margin
        };
    }

    function drawGridLines() {
        this.wrap.classed('gridlines', this.config.gridlines);
        if (this.config.gridlines) {
            this.svg.select('.y.axis').selectAll('.tick line').attr('x1', 0);
            this.svg.select('.x.axis').selectAll('.tick line').attr('y1', 0);
            if (this.config.gridlines === 'y' || this.config.gridlines === 'xy')
                this.svg.select('.y.axis').selectAll('.tick line').attr('x1', this.plot_width);
            if (this.config.gridlines === 'x' || this.config.gridlines === 'xy')
                this.svg.select('.x.axis').selectAll('.tick line').attr('y1', -this.plot_height);
        } else {
            this.svg.select('.y.axis').selectAll('.tick line').attr('x1', 0);
            this.svg.select('.x.axis').selectAll('.tick line').attr('y1', 0);
        }
    }

    function makeLegend() {
        var scale = arguments.length > 0 && arguments[0] !== undefined
            ? arguments[0]
            : this.colorScale;
        var label = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : '';
        var custom_data = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : null;

        var config = this.config;

        config.legend.mark = config.legend.mark
            ? config.legend.mark
            : config.marks.length && config.marks[0].type === 'bar'
              ? 'square'
              : config.marks.length ? config.marks[0].type : 'square';

        var legend_label = label
            ? label
            : typeof config.legend.label === 'string' ? config.legend.label : '';

        var legendOriginal = this.legend || this.wrap.select('.legend');
        var legend = legendOriginal;

        if (!this.parent) {
            //singular chart
            if (this.config.legend.location === 'top' || this.config.legend.location === 'left') {
                this.wrap.node().insertBefore(legendOriginal.node(), this.svg.node().parentNode);
            } else {
                this.wrap.node().appendChild(legendOriginal.node());
            }
        } else {
            //multiples - keep legend outside of individual charts' wraps
            if (this.config.legend.location === 'top' || this.config.legend.location === 'left') {
                this.parent.wrap
                    .node()
                    .insertBefore(
                        legendOriginal.node(),
                        this.parent.wrap.select('.wc-chart').node()
                    );
            } else {
                this.parent.wrap.node().appendChild(legendOriginal.node());
            }
        }

        legend.style('padding', 0);

        var legend_data =
            custom_data ||
            scale
                .domain()
                .slice(0)
                .filter(function(f) {
                    return f !== undefined && f !== null;
                })
                .map(function(m) {
                    return { label: m, mark: config.legend.mark };
                });

        legend
            .select('.legend-title')
            .text(legend_label)
            .style('display', legend_label ? 'inline' : 'none')
            .style('margin-right', '1em');

        var leg_parts = legend.selectAll('.legend-item').data(legend_data, function(d) {
            return d.label + d.mark;
        });

        leg_parts.exit().remove();

        var legendPartDisplay = this.config.legend.location === 'bottom' ||
            this.config.legend.location === 'top'
            ? 'inline-block'
            : 'block';
        var new_parts = leg_parts
            .enter()
            .append('li')
            .attr('class', 'legend-item')
            .style({ 'list-style-type': 'none', 'margin-right': '1em' });
        new_parts.append('span').attr('class', 'legend-mark-text').style('color', function(d) {
            return scale(d.label);
        });
        new_parts
            .append('svg')
            .attr('class', 'legend-color-block')
            .attr('width', '1.1em')
            .attr('height', '1.1em')
            .style({
                position: 'relative',
                top: '0.2em'
            });

        leg_parts.style('display', legendPartDisplay);

        if (config.legend.order) {
            leg_parts.sort(function(a, b) {
                return d3.ascending(
                    config.legend.order.indexOf(a.label),
                    config.legend.order.indexOf(b.label)
                );
            });
        }

        leg_parts.selectAll('.legend-color-block').select('.legend-mark').remove();
        leg_parts.selectAll('.legend-color-block').each(function(e) {
            var svg = d3.select(this);
            if (e.mark === 'circle') {
                svg.append('circle').attr({
                    cx: '.5em',
                    cy: '.5em',
                    r: '.45em',
                    class: 'legend-mark'
                });
            } else if (e.mark === 'line') {
                svg.append('line').attr({
                    x1: 0,
                    y1: '.5em',
                    x2: '1em',
                    y2: '.5em',
                    'stroke-width': 2,
                    'shape-rendering': 'crispEdges',
                    class: 'legend-mark'
                });
            } else if (e.mark === 'square') {
                svg.append('rect').attr({
                    height: '1em',
                    width: '1em',
                    class: 'legend-mark',
                    'shape-rendering': 'crispEdges'
                });
            }
        });
        leg_parts
            .selectAll('.legend-color-block')
            .select('.legend-mark')
            .attr('fill', function(d) {
                return d.color || scale(d.label);
            })
            .attr('stroke', function(d) {
                return d.color || scale(d.label);
            })
            .each(function(e) {
                d3.select(this).attr(e.attributes);
            });

        new_parts
            .append('span')
            .attr('class', 'legend-label')
            .style('margin-left', '0.25em')
            .text(function(d) {
                return d.label;
            });

        if (scale.domain().length > 0) {
            var legendDisplay = (this.config.legend.location === 'bottom' ||
                this.config.legend.location === 'top') &&
                !this.parent
                ? 'block'
                : 'inline-block';
            legend.style('display', legendDisplay);
        } else {
            legend.style('display', 'none');
        }

        this.legend = legend;
    }

    function updateDataMarks() {
        this.drawBars(
            this.marks.filter(function(f) {
                return f.type === 'bar';
            })
        );
        this.drawLines(
            this.marks.filter(function(f) {
                return f.type === 'line';
            })
        );
        this.drawPoints(
            this.marks.filter(function(f) {
                return f.type === 'circle';
            })
        );
        this.drawText(
            this.marks.filter(function(f) {
                return f.type === 'text';
            })
        );

        this.marks.supergroups = this.svg.selectAll('g.supergroup');
    }

    function drawArea(area_drawer, area_data, datum_accessor) {
        var class_match = arguments.length > 3 && arguments[3] !== undefined
            ? arguments[3]
            : 'chart-area';

        var _this = this;

        var bind_accessor = arguments[4];
        var attr_accessor = arguments.length > 5 && arguments[5] !== undefined
            ? arguments[5]
            : function(d) {
                  return d;
              };

        var area_grps = this.svg.selectAll('.' + class_match).data(area_data, bind_accessor);
        area_grps.exit().remove();
        area_grps
            .enter()
            .append('g')
            .attr('class', function(d) {
                return class_match + ' ' + d.key;
            })
            .append('path');

        var areaPaths = area_grps
            .select('path')
            .datum(datum_accessor)
            .attr('fill', function(d) {
                var d_attr = attr_accessor(d);
                return d_attr ? _this.colorScale(d_attr[_this.config.color_by]) : null;
            })
            .attr(
                'fill-opacity',
                this.config.fill_opacity || this.config.fill_opacity === 0
                    ? this.config.fill_opacity
                    : 0.3
            );

        //don't transition if config says not to
        var areaPathTransitions = this.config.transitions ? areaPaths.transition() : areaPaths;

        areaPathTransitions.attr('d', area_drawer);

        return area_grps;
    }

    function drawBars(marks) {
        var _this = this;

        var chart = this;
        var rawData = this.raw_data;
        var config = this.config;

        var bar_supergroups = this.svg.selectAll('.bar-supergroup').data(marks, function(d, i) {
            return i + '-' + d.per.join('-');
        });

        bar_supergroups.enter().append('g').attr('class', function(d) {
            return 'supergroup bar-supergroup ' + d.id;
        });

        bar_supergroups.exit().remove();

        var bar_groups = bar_supergroups.selectAll('.bar-group').data(
            function(d) {
                return d.data;
            },
            function(d) {
                return d.key;
            }
        );
        var old_bar_groups = bar_groups.exit();

        var nu_bar_groups = void 0;
        var bars = void 0;

        var oldBarsTrans = config.transitions
            ? old_bar_groups.selectAll('.bar').transition()
            : old_bar_groups.selectAll('.bar');
        var oldBarGroupsTrans = config.transitions ? old_bar_groups.transition() : old_bar_groups;

        if (config.x.type === 'ordinal') {
            oldBarsTrans.attr('y', this.y(0)).attr('height', 0);

            oldBarGroupsTrans.remove();

            nu_bar_groups = bar_groups.enter().append('g').attr('class', function(d) {
                return 'bar-group ' + d.key;
            });
            nu_bar_groups.append('title');

            bars = bar_groups.selectAll('rect').data(
                function(d) {
                    return d.values instanceof Array
                        ? d.values.sort(function(a, b) {
                              return (
                                  _this.colorScale.domain().indexOf(b.key) -
                                  _this.colorScale.domain().indexOf(a.key)
                              );
                          })
                        : [d];
                },
                function(d) {
                    return d.key;
                }
            );

            var exitBars = config.transitions ? bars.exit().transition() : bars.exit();
            exitBars.attr('y', this.y(0)).attr('height', 0).remove();
            bars
                .enter()
                .append('rect')
                .attr('class', function(d) {
                    return 'wc-data-mark bar ' + d.key;
                })
                .style('clip-path', 'url(#' + chart.id + ')')
                .attr('y', this.y(0))
                .attr('height', 0)
                .append('title');

            bars
                .attr('shape-rendering', 'crispEdges')
                .attr('stroke', function(d) {
                    return _this.colorScale(d.values.raw[0][config.color_by]);
                })
                .attr('fill', function(d) {
                    return _this.colorScale(d.values.raw[0][config.color_by]);
                });

            bars.each(function(d) {
                var mark = d3.select(this.parentNode.parentNode).datum();
                d.tooltip = mark.tooltip;
                d.arrange = mark.split && mark.arrange
                    ? mark.arrange
                    : mark.split ? 'grouped' : null;
                d.subcats = config.legend.order
                    ? config.legend.order.slice().reverse()
                    : mark.values && mark.values[mark.split]
                      ? mark.values[mark.split]
                      : d3
                            .set(
                                rawData.map(function(m) {
                                    return m[mark.split];
                                })
                            )
                            .values();
                d3.select(this).attr(mark.attributes);
            });

            var xformat = config.marks
                .map(function(m) {
                    return m.summarizeX === 'percent';
                })
                .indexOf(true) > -1
                ? d3.format('0%')
                : d3.format(config.x.format);
            var yformat = config.marks
                .map(function(m) {
                    return m.summarizeY === 'percent';
                })
                .indexOf(true) > -1
                ? d3.format('0%')
                : d3.format(config.y.format);
            bars.select('title').text(function(d) {
                var tt = d.tooltip || '';
                return tt
                    .replace(/\$x/g, xformat(d.values.x))
                    .replace(/\$y/g, yformat(d.values.y))
                    .replace(/\[(.+?)\]/g, function(str, orig) {
                        return d.values.raw[0][orig];
                    });
            });

            var barsTrans = config.transitions ? bars.transition() : bars;
            barsTrans
                .attr('x', function(d) {
                    var position = void 0;
                    if (!d.arrange || d.arrange === 'stacked') {
                        return _this.x(d.values.x);
                    } else if (d.arrange === 'nested') {
                        var _position = d.subcats.indexOf(d.key);
                        var offset = _position
                            ? _this.x.rangeBand() / (d.subcats.length * 0.75) / _position
                            : _this.x.rangeBand();
                        return _this.x(d.values.x) + (_this.x.rangeBand() - offset) / 2;
                    } else {
                        position = d.subcats.indexOf(d.key);
                        return (
                            _this.x(d.values.x) + _this.x.rangeBand() / d.subcats.length * position
                        );
                    }
                })
                .attr('y', function(d) {
                    if (d.arrange !== 'stacked') {
                        return _this.y(d.values.y);
                    } else {
                        return _this.y(d.values.start);
                    }
                })
                .attr('width', function(d) {
                    if (!d.arrange || d.arrange === 'stacked') {
                        return _this.x.rangeBand();
                    } else if (d.arrange === 'nested') {
                        var position = d.subcats.indexOf(d.key);
                        return position
                            ? _this.x.rangeBand() / (d.subcats.length * 0.75) / position
                            : _this.x.rangeBand();
                    } else {
                        return _this.x.rangeBand() / d.subcats.length;
                    }
                })
                .attr('height', function(d) {
                    return _this.y(0) - _this.y(d.values.y);
                });
        } else if (config.y.type === 'ordinal') {
            oldBarsTrans.attr('x', this.x(0)).attr('width', 0);

            oldBarGroupsTrans.remove();

            nu_bar_groups = bar_groups.enter().append('g').attr('class', function(d) {
                return 'bar-group ' + d.key;
            });
            nu_bar_groups.append('title');

            bars = bar_groups.selectAll('rect').data(
                function(d) {
                    return d.values instanceof Array
                        ? d.values.sort(function(a, b) {
                              return (
                                  _this.colorScale.domain().indexOf(b.key) -
                                  _this.colorScale.domain().indexOf(a.key)
                              );
                          })
                        : [d];
                },
                function(d) {
                    return d.key;
                }
            );

            var _exitBars = config.transitions ? bars.exit().transition() : bars.exit();
            _exitBars.attr('x', this.x(0)).attr('width', 0).remove();
            bars
                .enter()
                .append('rect')
                .attr('class', function(d) {
                    return 'wc-data-mark bar ' + d.key;
                })
                .style('clip-path', 'url(#' + chart.id + ')')
                .attr('x', this.x(0))
                .attr('width', 0)
                .append('title');

            bars
                .attr('shape-rendering', 'crispEdges')
                .attr('stroke', function(d) {
                    return _this.colorScale(d.values.raw[0][config.color_by]);
                })
                .attr('fill', function(d) {
                    return _this.colorScale(d.values.raw[0][config.color_by]);
                });

            bars.each(function(d) {
                var mark = d3.select(this.parentNode.parentNode).datum();
                d.arrange = mark.split && mark.arrange
                    ? mark.arrange
                    : mark.split ? 'grouped' : null;
                d.subcats = config.legend.order
                    ? config.legend.order.slice().reverse()
                    : mark.values && mark.values[mark.split]
                      ? mark.values[mark.split]
                      : d3
                            .set(
                                rawData.map(function(m) {
                                    return m[mark.split];
                                })
                            )
                            .values();
                d.tooltip = mark.tooltip;
                d3.select(this).attr(mark.attributes);
            });

            var _xformat = config.marks
                .map(function(m) {
                    return m.summarizeX === 'percent';
                })
                .indexOf(true) > -1
                ? d3.format('0%')
                : d3.format(config.x.format);
            var _yformat = config.marks
                .map(function(m) {
                    return m.summarizeY === 'percent';
                })
                .indexOf(true) > -1
                ? d3.format('0%')
                : d3.format(config.y.format);
            bars.select('title').text(function(d) {
                var tt = d.tooltip || '';
                return tt
                    .replace(/\$x/g, _xformat(d.values.x))
                    .replace(/\$y/g, _yformat(d.values.y))
                    .replace(/\[(.+?)\]/g, function(str, orig) {
                        return d.values.raw[0][orig];
                    });
            });

            var _barsTrans = config.transitions ? bars.transition() : bars;
            _barsTrans
                .attr('x', function(d) {
                    if (d.arrange === 'stacked' || !d.arrange) {
                        return d.values.start !== undefined ? _this.x(d.values.start) : _this.x(0);
                    } else {
                        return _this.x(0);
                    }
                })
                .attr('y', function(d) {
                    if (d.arrange === 'nested') {
                        var position = d.subcats.indexOf(d.key);
                        var offset = position
                            ? _this.y.rangeBand() / (d.subcats.length * 0.75) / position
                            : _this.y.rangeBand();
                        return _this.y(d.values.y) + (_this.y.rangeBand() - offset) / 2;
                    } else if (d.arrange === 'grouped') {
                        var _position2 = d.subcats.indexOf(d.key);
                        return (
                            _this.y(d.values.y) +
                            _this.y.rangeBand() / d.subcats.length * _position2
                        );
                    } else {
                        return _this.y(d.values.y);
                    }
                })
                .attr('width', function(d) {
                    return _this.x(d.values.x) - _this.x(0);
                })
                .attr('height', function(d) {
                    if (config.y.type === 'quantile') {
                        return 20;
                    } else if (d.arrange === 'nested') {
                        var position = d.subcats.indexOf(d.key);
                        return position
                            ? _this.y.rangeBand() / (d.subcats.length * 0.75) / position
                            : _this.y.rangeBand();
                    } else if (d.arrange === 'grouped') {
                        return _this.y.rangeBand() / d.subcats.length;
                    } else {
                        return _this.y.rangeBand();
                    }
                });
        } else if (['linear', 'log'].indexOf(config.x.type) > -1 && config.x.bin) {
            oldBarsTrans.attr('y', this.y(0)).attr('height', 0);

            oldBarGroupsTrans.remove();

            nu_bar_groups = bar_groups.enter().append('g').attr('class', function(d) {
                return 'bar-group ' + d.key;
            });
            nu_bar_groups.append('title');

            bars = bar_groups.selectAll('rect').data(
                function(d) {
                    return d.values instanceof Array ? d.values : [d];
                },
                function(d) {
                    return d.key;
                }
            );

            var _exitBars2 = config.transitions ? bars.exit().transition() : bars.exit();
            _exitBars2.attr('y', this.y(0)).attr('height', 0).remove();
            bars
                .enter()
                .append('rect')
                .attr('class', function(d) {
                    return 'wc-data-mark bar ' + d.key;
                })
                .style('clip-path', 'url(#' + chart.id + ')')
                .attr('y', this.y(0))
                .attr('height', 0)
                .append('title');

            bars
                .attr('shape-rendering', 'crispEdges')
                .attr('stroke', function(d) {
                    return _this.colorScale(d.values.raw[0][config.color_by]);
                })
                .attr('fill', function(d) {
                    return _this.colorScale(d.values.raw[0][config.color_by]);
                });

            bars.each(function(d) {
                var mark = d3.select(this.parentNode.parentNode).datum();
                d.arrange = mark.split ? mark.arrange : null;
                d.subcats = config.legend.order
                    ? config.legend.order.slice().reverse()
                    : mark.values && mark.values[mark.split]
                      ? mark.values[mark.split]
                      : d3
                            .set(
                                rawData.map(function(m) {
                                    return m[mark.split];
                                })
                            )
                            .values();
                d3.select(this).attr(mark.attributes);
                var parent = d3.select(this.parentNode).datum();
                var rangeSet = parent.key.split(',').map(function(m) {
                    return +m;
                });
                d.rangeLow = d3.min(rangeSet);
                d.rangeHigh = d3.max(rangeSet);
                d.tooltip = mark.tooltip;
            });

            var _xformat2 = config.marks
                .map(function(m) {
                    return m.summarizeX === 'percent';
                })
                .indexOf(true) > -1
                ? d3.format('0%')
                : d3.format(config.x.format);
            var _yformat2 = config.marks
                .map(function(m) {
                    return m.summarizeY === 'percent';
                })
                .indexOf(true) > -1
                ? d3.format('0%')
                : d3.format(config.y.format);
            bars.select('title').text(function(d) {
                var tt = d.tooltip || '';
                return tt
                    .replace(/\$x/g, _xformat2(d.values.x))
                    .replace(/\$y/g, _yformat2(d.values.y))
                    .replace(/\[(.+?)\]/g, function(str, orig) {
                        return d.values.raw[0][orig];
                    });
            });

            var _barsTrans2 = config.transitions ? bars.transition() : bars;
            _barsTrans2
                .attr('x', function(d) {
                    return _this.x(d.rangeLow);
                })
                .attr('y', function(d) {
                    if (d.arrange !== 'stacked') {
                        return _this.y(d.values.y);
                    } else {
                        return _this.y(d.values.start);
                    }
                })
                .attr('width', function(d) {
                    return _this.x(d.rangeHigh) - _this.x(d.rangeLow);
                })
                .attr('height', function(d) {
                    return _this.y(0) - _this.y(d.values.y);
                });
        } else if (
            ['linear', 'log'].indexOf(config.y.type) > -1 &&
            config.y.type === 'linear' &&
            config.y.bin
        ) {
            oldBarsTrans.attr('x', this.x(0)).attr('width', 0);
            oldBarGroupsTrans.remove();

            nu_bar_groups = bar_groups.enter().append('g').attr('class', function(d) {
                return 'bar-group ' + d.key;
            });
            nu_bar_groups.append('title');

            bars = bar_groups.selectAll('rect').data(
                function(d) {
                    return d.values instanceof Array ? d.values : [d];
                },
                function(d) {
                    return d.key;
                }
            );

            var _exitBars3 = config.transitions ? bars.exit().transition() : bars.exit();
            _exitBars3.attr('x', this.x(0)).attr('width', 0).remove();
            bars
                .enter()
                .append('rect')
                .attr('class', function(d) {
                    return 'wc-data-mark bar ' + d.key;
                })
                .style('clip-path', 'url(#' + chart.id + ')')
                .attr('x', this.x(0))
                .attr('width', 0)
                .append('title');

            bars
                .attr('shape-rendering', 'crispEdges')
                .attr('stroke', function(d) {
                    return _this.colorScale(d.values.raw[0][config.color_by]);
                })
                .attr('fill', function(d) {
                    return _this.colorScale(d.values.raw[0][config.color_by]);
                });

            bars.each(function(d) {
                var mark = d3.select(this.parentNode.parentNode).datum();
                d.arrange = mark.split ? mark.arrange : null;
                d.subcats = config.legend.order
                    ? config.legend.order.slice().reverse()
                    : mark.values && mark.values[mark.split]
                      ? mark.values[mark.split]
                      : d3
                            .set(
                                rawData.map(function(m) {
                                    return m[mark.split];
                                })
                            )
                            .values();
                var parent = d3.select(this.parentNode).datum();
                var rangeSet = parent.key.split(',').map(function(m) {
                    return +m;
                });
                d.rangeLow = d3.min(rangeSet);
                d.rangeHigh = d3.max(rangeSet);
                d.tooltip = mark.tooltip;
            });

            var _xformat3 = config.marks
                .map(function(m) {
                    return m.summarizeX === 'percent';
                })
                .indexOf(true) > -1
                ? d3.format('0%')
                : d3.format(config.x.format);
            var _yformat3 = config.marks
                .map(function(m) {
                    return m.summarizeY === 'percent';
                })
                .indexOf(true) > -1
                ? d3.format('0%')
                : d3.format(config.y.format);
            bars.select('title').text(function(d) {
                var tt = d.tooltip || '';
                return tt
                    .replace(/\$x/g, _xformat3(d.values.x))
                    .replace(/\$y/g, _yformat3(d.values.y))
                    .replace(/\[(.+?)\]/g, function(str, orig) {
                        return d.values.raw[0][orig];
                    });
            });

            var _barsTrans3 = config.transitions ? bars.transition() : bars;
            _barsTrans3
                .attr('x', function(d) {
                    if (d.arrange === 'stacked') {
                        return _this.x(d.values.start);
                    } else {
                        return _this.x(0);
                    }
                })
                .attr('y', function(d) {
                    return _this.y(d.rangeHigh);
                })
                .attr('width', function(d) {
                    return _this.x(d.values.x);
                })
                .attr('height', function(d) {
                    return _this.y(d.rangeLow) - _this.y(d.rangeHigh);
                });
        } else {
            oldBarsTrans.attr('y', this.y(0)).attr('height', 0);
            oldBarGroupsTrans.remove();
            bar_supergroups.remove();
        }

        //Link to the d3.selection from the data
        bar_supergroups.each(function(d) {
            d.supergroup = d3.select(this);
            d.groups = d.supergroup.selectAll('.bar-group');
        });
    }

    function drawLines(marks) {
        var _this = this;

        var chart = this;
        var config = this.config;
        var line = d3.svg
            .line()
            .interpolate(config.interpolate)
            .x(function(d) {
                return config.x.type === 'linear' || config.x.type == 'log'
                    ? _this.x(+d.values.x)
                    : config.x.type === 'time'
                      ? _this.x(new Date(d.values.x))
                      : _this.x(d.values.x) + _this.x.rangeBand() / 2;
            })
            .y(function(d) {
                return config.y.type === 'linear' || config.y.type == 'log'
                    ? _this.y(+d.values.y)
                    : config.y.type === 'time'
                      ? _this.y(new Date(d.values.y))
                      : _this.y(d.values.y) + _this.y.rangeBand() / 2;
            });

        var line_supergroups = this.svg.selectAll('.line-supergroup').data(marks, function(d, i) {
            return i + '-' + d.per.join('-');
        });

        line_supergroups.enter().append('g').attr('class', function(d) {
            return 'supergroup line-supergroup ' + d.id;
        });

        line_supergroups.exit().remove();

        var line_grps = line_supergroups.selectAll('.line').data(
            function(d) {
                return d.data;
            },
            function(d) {
                return d.key;
            }
        );
        line_grps.exit().remove();
        var nu_line_grps = line_grps.enter().append('g').attr('class', function(d) {
            return d.key + ' line';
        });
        nu_line_grps.append('path');
        nu_line_grps.append('title');

        var linePaths = line_grps
            .select('path')
            .attr('class', 'wc-data-mark')
            .style('clip-path', 'url(#' + chart.id + ')')
            .datum(function(d) {
                return d.values;
            })
            .attr('stroke', function(d) {
                return _this.colorScale(d[0].values.raw[0][config.color_by]);
            })
            .attr(
                'stroke-width',
                config.stroke_width ? config.stroke_width : config.flex_stroke_width
            )
            .attr('stroke-linecap', 'round')
            .attr('fill', 'none');
        var linePathsTrans = config.transitions ? linePaths.transition() : linePaths;
        linePathsTrans.attr('d', line);

        line_grps.each(function(d) {
            var mark = d3.select(this.parentNode).datum();
            d.tooltip = mark.tooltip;
            d3.select(this).select('path').attr(mark.attributes);
        });

        line_grps.select('title').text(function(d) {
            var tt = d.tooltip || '';
            var xformat = config.x.summary === 'percent'
                ? d3.format('0%')
                : d3.format(config.x.format);
            var yformat = config.y.summary === 'percent'
                ? d3.format('0%')
                : d3.format(config.y.format);
            return tt
                .replace(/\$x/g, xformat(d.values.x))
                .replace(/\$y/g, yformat(d.values.y))
                .replace(/\[(.+?)\]/g, function(str, orig) {
                    return d.values[0].values.raw[0][orig];
                });
        });

        //Link to the d3.selection from the data
        line_supergroups.each(function(d) {
            d.supergroup = d3.select(this);
            d.groups = d.supergroup.selectAll('g.line');
            d.paths = d.groups.select('path');
        });
        return line_grps;
    }

    function drawPoints(marks) {
        var _this = this;

        var chart = this;
        var config = this.config;

        var point_supergroups = this.svg.selectAll('.point-supergroup').data(marks, function(d, i) {
            return i + '-' + d.per.join('-');
        });

        point_supergroups.enter().append('g').attr('class', function(d) {
            return 'supergroup point-supergroup ' + d.id;
        });

        point_supergroups.exit().remove();

        var points = point_supergroups.selectAll('.point').data(
            function(d) {
                return d.data;
            },
            function(d) {
                return d.key;
            }
        );
        var oldPoints = points.exit();

        var oldPointsTrans = config.transitions
            ? oldPoints.selectAll('circle').transition()
            : oldPoints.selectAll('circle');
        oldPointsTrans.attr('r', 0);

        var oldPointGroupTrans = config.transitions ? oldPoints.transition() : oldPoints;
        oldPointGroupTrans.remove();

        var nupoints = points.enter().append('g').attr('class', function(d) {
            return d.key + ' point';
        });
        nupoints.append('circle').attr('class', 'wc-data-mark').attr('r', 0);
        nupoints.append('title');
        //static attributes
        points
            .select('circle')
            .style('clip-path', 'url(#' + chart.id + ')')
            .attr(
                'fill-opacity',
                config.fill_opacity || config.fill_opacity === 0 ? config.fill_opacity : 0.6
            )
            .attr('fill', function(d) {
                return _this.colorScale(d.values.raw[0][config.color_by]);
            })
            .attr('stroke', function(d) {
                return _this.colorScale(d.values.raw[0][config.color_by]);
            });
        //attach mark info
        points.each(function(d) {
            var mark = d3.select(this.parentNode).datum();
            d.mark = mark;
            d3.select(this).select('circle').attr(mark.attributes);
        });
        //animated attributes
        var pointsTrans = config.transitions
            ? points.select('circle').transition()
            : points.select('circle');
        pointsTrans
            .attr('r', function(d) {
                return d.mark.radius || config.flex_point_size;
            })
            .attr('cx', function(d) {
                var x_pos = _this.x(d.values.x) || 0;
                return config.x.type === 'ordinal' ? x_pos + _this.x.rangeBand() / 2 : x_pos;
            })
            .attr('cy', function(d) {
                var y_pos = _this.y(d.values.y) || 0;
                return config.y.type === 'ordinal' ? y_pos + _this.y.rangeBand() / 2 : y_pos;
            });

        points.select('title').text(function(d) {
            var tt = d.mark.tooltip || '';
            var xformat = config.x.summary === 'percent'
                ? d3.format('0%')
                : config.x.type === 'time'
                  ? d3.time.format(config.x.format)
                  : d3.format(config.x.format);
            var yformat = config.y.summary === 'percent'
                ? d3.format('0%')
                : config.y.type === 'time'
                  ? d3.time.format(config.y.format)
                  : d3.format(config.y.format);
            return tt
                .replace(
                    /\$x/g,
                    config.x.type === 'time' ? xformat(new Date(d.values.x)) : xformat(d.values.x)
                )
                .replace(
                    /\$y/g,
                    config.y.type === 'time' ? yformat(new Date(d.values.y)) : yformat(d.values.y)
                )
                .replace(/\[(.+?)\]/g, function(str, orig) {
                    return d.values.raw[0][orig];
                });
        });

        //Link to the d3.selection from the data
        point_supergroups.each(function(d) {
            d.supergroup = d3.select(this);
            d.groups = d.supergroup.selectAll('g.point');
            d.circles = d.groups.select('circle');
        });

        return points;
    }

    function drawText(marks) {
        var _this = this;

        var chart = this;
        var config = this.config;

        var textSupergroups = this.svg.selectAll('.text-supergroup').data(marks, function(d, i) {
            return i + '-' + d.per.join('-');
        });

        textSupergroups.enter().append('g').attr('class', function(d) {
            return 'supergroup text-supergroup ' + d.id;
        });

        textSupergroups.exit().remove();

        var texts = textSupergroups.selectAll('.text').data(
            function(d) {
                return d.data;
            },
            function(d) {
                return d.key;
            }
        );
        var oldTexts = texts.exit();

        // don't need to transition position of outgoing text
        // const oldTextsTrans = config.transitions ? oldTexts.selectAll('text').transition() : oldTexts.selectAll('text');

        var oldTextGroupTrans = config.transitions ? oldTexts.transition() : oldTexts;
        oldTextGroupTrans.remove();

        var nutexts = texts.enter().append('g').attr('class', function(d) {
            return d.key + ' text';
        });
        nutexts.append('text').attr('class', 'wc-data-mark');
        // don't need to set initial location for incoming text

        // attach mark info
        function attachMarks(d) {
            d.mark = d3.select(this.parentNode).datum();
            d3.select(this).select('text').attr(d.mark.attributes);
        }
        texts.each(attachMarks);

        // parse text like tooltips
        texts.select('text').style('clip-path', 'url(#' + chart.id + ')').text(function(d) {
            var tt = d.mark.text || '';
            var xformat = config.x.summary === 'percent'
                ? d3.format('0%')
                : config.x.type === 'time'
                  ? d3.time.format(config.x.format)
                  : d3.format(config.x.format);
            var yformat = config.y.summary === 'percent'
                ? d3.format('0%')
                : config.y.type === 'time'
                  ? d3.time.format(config.y.format)
                  : d3.format(config.y.format);
            return tt
                .replace(
                    /\$x/g,
                    config.x.type === 'time' ? xformat(new Date(d.values.x)) : xformat(d.values.x)
                )
                .replace(
                    /\$y/g,
                    config.y.type === 'time' ? yformat(new Date(d.values.y)) : yformat(d.values.y)
                )
                .replace(/\[(.+?)\]/g, function(str, orig) {
                    return d.values.raw[0][orig];
                });
        });
        // animated attributes
        var textsTrans = config.transitions
            ? texts.select('text').transition()
            : texts.select('text');
        textsTrans
            .attr('x', function(d) {
                var xPos = _this.x(d.values.x) || 0;
                return config.x.type === 'ordinal' ? xPos + _this.x.rangeBand() / 2 : xPos;
            })
            .attr('y', function(d) {
                var yPos = _this.y(d.values.y) || 0;
                return config.y.type === 'ordinal' ? yPos + _this.y.rangeBand() / 2 : yPos;
            });
        //add a reference to the selection from it's data
        textSupergroups.each(function(d) {
            d.supergroup = d3.select(this);
            d.groups = d.supergroup.selectAll('g.text');
            d.texts = d.groups.select('text');
        });
        return texts;
    }

    function destroy() {
        var destroyControls = arguments.length > 0 && arguments[0] !== undefined
            ? arguments[0]
            : true;

        //run onDestroy callback
        this.events.onDestroy.call(this);

        //remove resize event listener
        var context = this;
        d3.select(window).on('resize.' + context.element + context.id, null);

        //destroy controls
        if (destroyControls && this.controls) {
            this.controls.destroy();
        }

        //unmount chart wrapper
        this.wrap.remove();
    }

    var chartProto = {
        raw_data: [],
        config: {}
    };

    var chart = Object.create(chartProto, {
        checkRequired: { value: checkRequired },
        consolidateData: { value: consolidateData },
        draw: { value: draw },
        destroy: { value: destroy },
        drawArea: { value: drawArea },
        drawBars: { value: drawBars },
        drawGridlines: { value: drawGridLines },
        drawLines: { value: drawLines },
        drawPoints: { value: drawPoints },
        drawText: { value: drawText },
        init: { value: init },
        layout: { value: layout },
        makeLegend: { value: makeLegend },
        resize: { value: resize },
        setColorScale: { value: setColorScale },
        setDefaults: { value: setDefaults },
        setMargins: { value: setMargins },
        textSize: { value: textSize },
        transformData: { value: transformData },
        updateDataMarks: { value: updateDataMarks },
        xScaleAxis: { value: xScaleAxis },
        yScaleAxis: { value: yScaleAxis }
    });

    var chartCount = 0;

    function createChart() {
        var element = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'body';
        var config = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
        var controls = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : null;

        var thisChart = Object.create(chart);

        thisChart.div = element;

        thisChart.config = Object.create(config);

        thisChart.controls = controls;

        thisChart.raw_data = [];

        thisChart.filters = [];

        thisChart.marks = [];

        thisChart.wrap = d3.select(thisChart.div).append('div').datum(thisChart);

        thisChart.events = {
            onInit: function onInit() {},
            onLayout: function onLayout() {},
            onPreprocess: function onPreprocess() {},
            onDatatransform: function onDatatransform() {},
            onDraw: function onDraw() {},
            onResize: function onResize() {},
            onDestroy: function onDestroy() {}
        };

        thisChart.on = function(event, callback) {
            var possible_events = [
                'init',
                'layout',
                'preprocess',
                'datatransform',
                'draw',
                'resize',
                'destroy'
            ];
            if (possible_events.indexOf(event) < 0) {
                return;
            }
            if (callback) {
                thisChart.events['on' + event.charAt(0).toUpperCase() + event.slice(1)] = callback;
            }
        };

        //increment thisChart count to get unique thisChart id
        chartCount++;

        thisChart.id = chartCount;

        return thisChart;
    }

    function changeOption(option, value, callback, draw) {
        var _this = this;

        this.targets.forEach(function(target) {
            if (option instanceof Array) {
                option.forEach(function(o) {
                    return _this.stringAccessor(target.config, o, value);
                });
            } else {
                _this.stringAccessor(target.config, option, value);
            }
            //call callback function if provided
            if (callback) {
                callback();
            }
            if (draw) target.draw();
        });
    }

    function checkRequired$1(dataset) {
        if (!dataset[0] || !this.config.inputs) return;

        var colNames = d3.keys(dataset[0]);

        this.config.inputs.forEach(function(input, i) {
            if (input.type === 'subsetter' && colNames.indexOf(input.value_col) === -1)
                throw new Error(
                    'Error in settings object: the value "' +
                        input.value_col +
                        '" does not match any column in the provided dataset.'
                );

            //Draw the chart when a control changes unless the user specifies otherwise.
            input.draw = input.draw === undefined ? true : input.draw;
        });
    }

    function controlUpdate() {
        var _this = this;

        if (this.config.inputs && this.config.inputs.length && this.config.inputs[0])
            this.config.inputs.forEach(function(input) {
                return _this.makeControlItem(input);
            });
    }

    function destroy$1() {
        //unmount controls wrapper
        this.wrap.remove();
    }

    function init$1(data) {
        this.data = data;
        if (!this.config.builder) this.checkRequired(this.data);
        this.layout();
    }

    function layout$1() {
        this.wrap.selectAll('*').remove();
        this.ready = true;
        this.controlUpdate();
    }

    function makeControlItem(control) {
        var control_wrap = this.wrap
            .append('div')
            .attr('class', 'control-group')
            .classed('inline', control.inline)
            .datum(control);

        //Add control label span.
        var ctrl_label = control_wrap
            .append('span')
            .attr('class', 'wc-control-label')
            .text(control.label);

        //Add control _Required_ text to control label span.
        if (control.required)
            ctrl_label.append('span').attr('class', 'label label-required').text('Required');

        //Add control description span.
        control_wrap.append('span').attr('class', 'span-description').text(control.description);

        if (control.type === 'text') {
            this.makeTextControl(control, control_wrap);
        } else if (control.type === 'number') {
            this.makeNumberControl(control, control_wrap);
        } else if (control.type === 'list') {
            this.makeListControl(control, control_wrap);
        } else if (control.type === 'dropdown') {
            this.makeDropdownControl(control, control_wrap);
        } else if (control.type === 'btngroup') {
            this.makeBtnGroupControl(control, control_wrap);
        } else if (control.type === 'checkbox') {
            this.makeCheckboxControl(control, control_wrap);
        } else if (control.type === 'radio') {
            this.makeRadioControl(control, control_wrap);
        } else if (control.type === 'subsetter') {
            this.makeSubsetterControl(control, control_wrap);
        } else {
            throw new Error(
                'Each control must have a type! Choose from: "text", "number", "list", "dropdown", "btngroup", "checkbox", "radio", or "subsetter".'
            );
        }
    }

    function makeBtnGroupControl(control, control_wrap) {
        var _this = this;

        var option_data = control.values ? control.values : d3.keys(this.data[0]);

        var btn_wrap = control_wrap.append('div').attr('class', 'btn-group');

        var changers = btn_wrap
            .selectAll('button')
            .data(option_data)
            .enter()
            .append('button')
            .attr('class', 'btn btn-default btn-sm')
            .text(function(d) {
                return d;
            })
            .classed('btn-primary', function(d) {
                return _this.stringAccessor(_this.targets[0].config, control.option) === d;
            });

        changers.on('click', function(d) {
            changers.each(function(e) {
                d3.select(this).classed('btn-primary', e === d);
            });
            _this.changeOption(control.option, d, control.callback, control.draw);
        });
    }

    function makeCheckboxControl(control, control_wrap) {
        var _this = this;

        var changer = control_wrap
            .append('input')
            .attr('type', 'checkbox')
            .attr('class', 'changer')
            .datum(control)
            .property('checked', function(d) {
                return _this.stringAccessor(_this.targets[0].config, control.option);
            });

        changer.on('change', function(d) {
            var value = changer.property('checked');
            _this.changeOption(d.option, value, control.callback, control.draw);
        });
    }

    function makeDropdownControl(control, control_wrap) {
        var _this = this;

        var mainOption = control.option || control.options[0];
        var changer = control_wrap
            .append('select')
            .attr('class', 'changer')
            .attr('multiple', control.multiple ? true : null)
            .datum(control);

        var opt_values = control.values && control.values instanceof Array
            ? control.values
            : control.values
              ? d3
                    .set(
                        this.data.map(function(m) {
                            return m[_this.targets[0].config[control.values]];
                        })
                    )
                    .values()
              : d3.keys(this.data[0]);

        if (!control.require || control.none) {
            opt_values.unshift('None');
        }

        var options = changer
            .selectAll('option')
            .data(opt_values)
            .enter()
            .append('option')
            .text(function(d) {
                return d;
            })
            .property('selected', function(d) {
                return _this.stringAccessor(_this.targets[0].config, mainOption) === d;
            });

        changer.on('change', function(d) {
            var value = changer.property('value') === 'None' ? null : changer.property('value');

            if (control.multiple) {
                value = options
                    .filter(function(f) {
                        return d3.select(this).property('selected');
                    })[0]
                    .map(function(m) {
                        return d3.select(m).property('value');
                    })
                    .filter(function(f) {
                        return f !== 'None';
                    });
            }

            if (control.options) {
                _this.changeOption(control.options, value, control.callback, control.draw);
            } else {
                _this.changeOption(control.option, value, control.callback, control.draw);
            }
        });

        return changer;
    }

    function makeListControl(control, control_wrap) {
        var _this = this;

        var changer = control_wrap
            .append('input')
            .attr('type', 'text')
            .attr('class', 'changer')
            .datum(control)
            .property('value', function(d) {
                return _this.stringAccessor(_this.targets[0].config, control.option);
            });

        changer.on('change', function(d) {
            var value = changer.property('value')
                ? changer.property('value').split(',').map(function(m) {
                      return m.trim();
                  })
                : null;
            _this.changeOption(control.option, value, control.callback, control.draw);
        });
    }

    function makeNumberControl(control, control_wrap) {
        var _this = this;

        var changer = control_wrap
            .append('input')
            .attr('type', 'number')
            .attr('min', control.min !== undefined ? control.min : 0)
            .attr('max', control.max)
            .attr('step', control.step || 1)
            .attr('class', 'changer')
            .datum(control)
            .property('value', function(d) {
                return _this.stringAccessor(_this.targets[0].config, control.option);
            });

        changer.on('change', function(d) {
            var value = +changer.property('value');
            _this.changeOption(control.option, value, control.callback, control.draw);
        });
    }

    function makeRadioControl(control, control_wrap) {
        var _this = this;

        var changers = control_wrap
            .selectAll('label')
            .data(control.values || d3.keys(this.data[0]))
            .enter()
            .append('label')
            .attr('class', 'radio')
            .text(function(d, i) {
                return control.relabels ? control.relabels[i] : d;
            })
            .append('input')
            .attr('type', 'radio')
            .attr('class', 'changer')
            .attr('name', control.option.replace('.', '-') + '-' + this.targets[0].id)
            .property('value', function(d) {
                return d;
            })
            .property('checked', function(d) {
                return _this.stringAccessor(_this.targets[0].config, control.option) === d;
            });

        changers.on('change', function(d) {
            var value = null;
            changers.each(function(c) {
                if (d3.select(this).property('checked')) {
                    value = d3.select(this).property('value') === 'none' ? null : c;
                }
            });
            _this.changeOption(control.option, value, control.callback, control.draw);
        });
    }

    function makeSubsetterControl(control, control_wrap) {
        var targets = this.targets; // associated charts and tables.

        //dropdown selection
        var changer = control_wrap
            .append('select')
            .classed('changer', true)
            .attr('multiple', control.multiple ? true : null)
            .datum(control);

        //dropdown option data
        var option_data = control.values
            ? control.values
            : d3
                  .set(
                      this.data
                          .map(function(m) {
                              return m[control.value_col];
                          })
                          .filter(function(f) {
                              return f;
                          })
                  )
                  .values()
                  .sort(naturalSorter); // only sort when values are derived

        //initial dropdown option
        control.start = control.start ? control.start : control.loose ? option_data[0] : null;

        //conditionally add All option
        if (!control.multiple && !control.start) {
            option_data.unshift('All');
            control.all = true;
        } else {
            control.all = false;
        }

        //what does loose mean?
        control.loose = !control.loose && control.start ? true : control.loose;

        //dropdown options selection
        var options = changer
            .selectAll('option')
            .data(option_data)
            .enter()
            .append('option')
            .text(function(d) {
                return d;
            })
            .property('selected', function(d) {
                return d === control.start;
            });

        //define filter object for each associated target
        targets.forEach(function(e) {
            var match = e.filters
                .slice()
                .map(function(m) {
                    return m.col === control.value_col;
                })
                .indexOf(true);
            if (match > -1) {
                e.filters[match] = {
                    col: control.value_col,
                    val: control.start ? control.start : !control.multiple ? 'All' : option_data,
                    index: 0,
                    choices: option_data,
                    loose: control.loose,
                    all: control.all
                };
            } else {
                e.filters.push({
                    col: control.value_col,
                    val: control.start ? control.start : !control.multiple ? 'All' : option_data,
                    index: 0,
                    choices: option_data,
                    loose: control.loose,
                    all: control.all
                });
            }
        });

        function setSubsetter(target, obj) {
            var match = -1;
            target.filters.forEach(function(e, i) {
                if (e.col === obj.col) {
                    match = i;
                }
            });
            if (match > -1) {
                target.filters[match] = obj;
            }
        }

        //add event listener to control
        changer.on('change', function(d) {
            if (control.multiple) {
                var values = options
                    .filter(function(f) {
                        return d3.select(this).property('selected');
                    })[0]
                    .map(function(m) {
                        return d3.select(m).property('text');
                    });

                var new_filter = {
                    col: control.value_col,
                    val: values,
                    index: null, //  could specify an array of indices but seems like a waste of resources give it doesn't inform anything without an overall 'All'
                    choices: option_data,
                    loose: control.loose,
                    all: control.all
                };
                targets.forEach(function(e) {
                    setSubsetter(e, new_filter);
                    //call callback function if provided
                    if (control.callback) {
                        control.callback();
                    }
                    if (control.draw) e.draw();
                });
            } else {
                var value = d3.select(this).select('option:checked').property('text');
                var index = d3.select(this).select('option:checked').property('index');
                var _new_filter = {
                    col: control.value_col,
                    val: value,
                    index: index,
                    choices: option_data,
                    loose: control.loose,
                    all: control.all
                };
                targets.forEach(function(e) {
                    setSubsetter(e, _new_filter);
                    //call callback function if provided
                    if (control.callback) {
                        control.callback();
                    }
                    e.draw();
                });
            }
        });
    }

    function makeTextControl(control, control_wrap) {
        var _this = this;

        var changer = control_wrap
            .append('input')
            .attr('type', 'text')
            .attr('class', 'changer')
            .datum(control)
            .property('value', function(d) {
                return _this.stringAccessor(_this.targets[0].config, control.option);
            });

        changer.on('change', function(d) {
            var value = changer.property('value');
            _this.changeOption(control.option, value, control.callback, control.draw);
        });
    }

    function stringAccessor(o, s, v) {
        //adapted from http://jsfiddle.net/alnitak/hEsys/
        s = s.replace(/\[(\w+)\]/g, '.$1');
        s = s.replace(/^\./, '');
        var a = s.split('.');
        for (var i = 0, n = a.length; i < n; ++i) {
            var k = a[i];
            if (k in o) {
                if (i == n - 1 && v !== undefined) o[k] = v;
                o = o[k];
            } else {
                return;
            }
        }
        return o;
    }

    var controls = {
        changeOption: changeOption,
        checkRequired: checkRequired$1,
        controlUpdate: controlUpdate,
        destroy: destroy$1,
        init: init$1,
        layout: layout$1,
        makeControlItem: makeControlItem,
        makeBtnGroupControl: makeBtnGroupControl,
        makeCheckboxControl: makeCheckboxControl,
        makeDropdownControl: makeDropdownControl,
        makeListControl: makeListControl,
        makeNumberControl: makeNumberControl,
        makeRadioControl: makeRadioControl,
        makeSubsetterControl: makeSubsetterControl,
        makeTextControl: makeTextControl,
        stringAccessor: stringAccessor
    };

    function createControls() {
        var element = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'body';
        var config = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

        var thisControls = Object.create(controls);

        thisControls.div = element;

        thisControls.config = Object.create(config);
        thisControls.config.inputs = thisControls.config.inputs || [];

        thisControls.targets = [];

        if (config.location === 'bottom') {
            thisControls.wrap = d3.select(element).append('div').attr('class', 'wc-controls');
        } else {
            thisControls.wrap = d3
                .select(element)
                .insert('div', ':first-child')
                .attr('class', 'wc-controls');
        }

        thisControls.wrap.datum(thisControls);

        return thisControls;
    }

    function applyFilters() {
        var _this = this;

        //If there are filters, return a filtered data array of the raw data.
        //Otherwise return the raw data.
        if (
            this.filters &&
            this.filters.some(function(filter) {
                return (
                    (typeof filter.val === 'string' &&
                        !(filter.all === true && filter.index === 0)) ||
                    (Array.isArray(filter.val) && filter.val.length < filter.choices.length)
                );
            })
        ) {
            this.data.filtered = this.data.raw;
            this.filters
                .filter(function(filter) {
                    return (
                        (typeof filter.val === 'string' &&
                            !(filter.all === true && filter.index === 0)) ||
                        (Array.isArray(filter.val) && filter.val.length < filter.choices.length)
                    );
                })
                .forEach(function(filter) {
                    _this.data.filtered = _this.data.filtered.filter(function(d) {
                        return Array.isArray(filter.val)
                            ? filter.val.indexOf(d[filter.col]) > -1
                            : filter.val === d[filter.col];
                    });
                });
        } else this.data.filtered = this.data.raw;
    }

    function updateDataObject() {
        this.data.raw = this.data.passed;
        this.data.filtered = this.data.passed;
        this.config.activePage = 0;
        this.config.startIndex = this.config.activePage * this.config.nRowsPerPage; // first row shown
        this.config.endIndex = this.config.startIndex + this.config.nRowsPerPage; // last row shown
    }

    function applySearchTerm(data) {
        var _this = this;

        if (this.searchable.searchTerm) {
            //Determine which rows contain input text.
            this.data.searched = this.data.filtered.filter(function(d) {
                var match = false;

                Object.keys(d)
                    .filter(function(key) {
                        return _this.config.cols.indexOf(key) > -1;
                    })
                    .forEach(function(var_name) {
                        if (match === false) {
                            var cellText = '' + d[var_name];
                            match =
                                cellText.toLowerCase().indexOf(_this.searchable.searchTerm) > -1;
                        }
                    });

                return match;
            });
            this.data.processing = this.data.searched;
        } else {
            //Otherwise delete previously searched data and set data to filtered data.
            delete this.data.searched;
            this.data.processing = this.data.filtered;
        }
    }

    /*------------------------------------------------------------------------------------------------\
      Check equality of two arrays (https://stackoverflow.com/questions/7837456/how-to-compare-arrays-in-javascript)
    \------------------------------------------------------------------------------------------------*/

    // Warn if overriding existing method
    if (Array.prototype.equals)
        console.warn(
            "Overriding existing Array.prototype.equals. Possible causes: New API defines the method, there's a framework conflict or you've got double inclusions in your code."
        );
    // attach the .equals method to Array's prototype to call it on any array
    Array.prototype.equals = function(array) {
        // if the other array is a falsy value, return
        if (!array) return false;

        // compare lengths - can save a lot of time
        if (this.length != array.length) return false;

        for (var i = 0, l = this.length; i < l; i++) {
            // Check if we have nested arrays
            if (this[i] instanceof Array && array[i] instanceof Array) {
                // recurse into the nested arrays
                if (!this[i].equals(array[i])) return false;
            } else if (this[i] != array[i]) {
                // Warning - two different object instances will never be equal: {x:20} != {x:20}
                return false;
            }
        }
        return true;
    };
    // Hide method from for-in loops
    Object.defineProperty(Array.prototype, 'equals', { enumerable: false });

    function checkFilters() {
        if (this.filters) {
            this.currentFilters = this.filters.map(function(filter) {
                return filter.val;
            });

            //Reset pagination if filters have changed.
            if (!this.currentFilters.equals(this.previousFilters)) {
                this.config.activePage = 0;
                this.config.startIndex = this.config.activePage * this.config.nRowsPerPage; // first row shown
                this.config.endIndex = this.config.startIndex + this.config.nRowsPerPage; // last row shown
            }

            this.previousFilters = this.currentFilters;
        }
    }

    function updateTableHeaders() {
        var _this = this;

        this.thead_cells = this.thead
            .select('tr')
            .selectAll('th')
            .data(this.config.headers, function(d) {
                return d;
            });
        this.thead_cells.exit().remove();
        this.thead_cells.enter().append('th');
        this.thead_cells
            .sort(function(a, b) {
                return _this.config.headers.indexOf(a) - _this.config.headers.indexOf(b);
            })
            .attr('class', function(d) {
                return _this.config.cols[_this.config.headers.indexOf(d)];
            }) // associate column header with column name
            .text(function(d) {
                return d;
            });
    }

    function drawTableBody() {
        var _this = this;

        var table = this;

        //Define table body rows.
        var rows = this.tbody.selectAll('tr').data(this.data.processing).enter().append('tr');

        //Define table body cells.
        var cells = rows.selectAll('td').data(function(d) {
            return _this.config.cols.map(function(key) {
                return { col: key, text: d[key] };
            });
        });
        cells.exit().remove();
        cells.enter().append('td');
        cells
            .sort(function(a, b) {
                return _this.config.cols.indexOf(a.col) - _this.config.cols.indexOf(b.col);
            })
            .attr('class', function(d) {
                return d.col;
            })
            .each(function(d) {
                var cell = d3.select(this);

                //Apply text in data as html or as plain text.
                if (table.config.as_html) {
                    cell.html(d.text);
                } else {
                    cell.text(d.text);
                }
            });
    }

    function dynamicLayout() {
        var widths = {
            table: this.table.select('thead').node().offsetWidth,
            top:
                this.wrap.select('.table-top .searchable-container').node().offsetWidth +
                    this.wrap.select('.table-top .sortable-container').node().offsetWidth,
            bottom:
                this.wrap.select('.table-bottom .pagination-container').node().offsetWidth +
                    this.wrap.select('.table-bottom .exportable-container').node().offsetWidth
        };

        if (
            widths.table < Math.max(widths.top, widths.bottom) &&
            this.config.layout === 'horizontal'
        ) {
            this.config.layout = 'vertical';
            this.wrap
                .style('display', 'inline-block')
                .selectAll('.table-top,.table-bottom')
                .style('display', 'inline-block')
                .selectAll('.interactivity')
                .style({
                    display: 'block',
                    clear: 'both'
                });
        } else if (
            widths.table >= Math.max(widths.top, widths.bottom) &&
            this.config.layout === 'vertical'
        ) {
            this.config.layout = 'horizontal';
            this.wrap
                .style('display', 'table')
                .selectAll('.table-top,.table-bottom')
                .style('display', 'block')
                .selectAll('.interactivity')
                .style({
                    display: 'inline-block',
                    float: function float() {
                        return d3.select(this).classed('searchable-container') ||
                            d3.select(this).classed('pagination-container')
                            ? 'right'
                            : null;
                    },
                    clear: null
                });
        }
    }

    function draw$1(passed_data) {
        var _this = this;

        var table = this;
        var config = this.config;

        this.data.passed = passed_data; // make passed data available on preprocess
        this.events.onPreprocess.call(this);

        if (!passed_data)
            //Apply filters if data is not passed to table.draw().
            applyFilters.call(this);
        else
            //Otherwise update data object.
            updateDataObject.call(this);

        //Compare current filter settings to previous filter settings, if any.
        checkFilters.call(this);

        //Filter data on search term if it exists and set data to searched data.
        applySearchTerm.call(this);

        this.searchable.wrap
            .select('.nNrecords')
            .text(
                this.data.processing.length === this.data.raw.length
                    ? this.data.raw.length + ' records displayed'
                    : this.data.processing.length +
                          '/' +
                          this.data.raw.length +
                          ' records displayed'
            );

        //Update table headers.
        updateTableHeaders.call(this);

        //Clear table body rows.
        this.tbody.selectAll('tr').remove();

        //Print a note that no data was selected for empty tables.
        if (this.data.processing.length === 0) {
            this.tbody
                .append('tr')
                .classed('no-data', true)
                .append('td')
                .attr('colspan', this.config.cols.length)
                .text('No data selected.');

            //Bind table filtered/searched data to table container.
            this.data.current = this.data.processing;
            this.table.datum(this.table.current);

            //Add export.
            if (this.config.exportable)
                this.config.exports.forEach(function(fmt) {
                    _this.exportable.exports[fmt].call(_this, _this.data.processing);
                });

            //Add pagination.
            if (this.config.pagination)
                this.pagination.addPagination.call(this, this.data.processing);
        } else {
            //Sort data.
            if (this.config.sortable) {
                this.thead.selectAll('th').on('click', function(header) {
                    table.sortable.onClick.call(table, this, header);
                });

                if (this.sortable.order.length)
                    this.sortable.sortData.call(this, this.data.processing);
            }

            //Bind table filtered/searched data to table container.
            this.data.current = this.data.processing;
            this.table.datum(this.data.current);

            //Add export.
            if (this.config.exportable)
                this.config.exports.forEach(function(fmt) {
                    _this.exportable.exports[fmt].call(_this, _this.data.processing);
                });

            //Add pagination.
            if (this.config.pagination) {
                this.pagination.addPagination.call(this, this.data.processing);

                //Apply pagination.
                this.data.processing = this.data.processing.filter(function(d, i) {
                    return _this.config.startIndex <= i && i < _this.config.endIndex;
                });
            }

            //Define table body rows.
            drawTableBody.call(this);
        }

        //Alter table layout if table is narrower than table top or bottom.
        if (this.config.dynamicPositioning) {
            dynamicLayout.call(this);
        }

        this.events.onDraw.call(this);
    }

    function layout$2() {
        var context = this;

        this.searchable.wrap = this.wrap
            .select('.table-top')
            .append('div')
            .classed('interactivity searchable-container', true)
            .classed('hidden', !this.config.searchable);
        this.searchable.wrap.append('div').classed('search', true);
        this.searchable.wrap
            .select('.search')
            .append('input')
            .classed('search-box', true)
            .attr('placeholder', 'Search')
            .on('input', function() {
                context.searchable.searchTerm = this.value.toLowerCase() || null;
                context.config.activePage = 0;
                context.config.startIndex = context.config.activePage * context.config.nRowsPerPage; // first row shown
                context.config.endIndex = context.config.startIndex + context.config.nRowsPerPage; // last row shown
                context.draw();
            });
        this.searchable.wrap.select('.search').append('span').classed('nNrecords', true);
    }

    function searchable() {
        return {
            layout: layout$2
        };
    }

    function layout$3() {
        var _this = this;

        this.exportable.wrap = this.wrap
            .select('.table-bottom')
            .append('div')
            .classed('interactivity exportable-container', true)
            .classed('hidden', !this.config.exportable);

        this.exportable.wrap.append('span').text('Export:');

        if (this.config.exports && this.config.exports.length)
            this.config.exports.forEach(function(fmt) {
                _this.exportable.wrap
                    .append('a')
                    .classed('wc-button export', true)
                    .attr({
                        id: fmt
                    })
                    .style(
                        !_this.test && navigator.msSaveBlob
                            ? {
                                  cursor: 'pointer',
                                  'text-decoration': 'underline',
                                  color: 'blue'
                              }
                            : null
                    )
                    .text(fmt.toUpperCase());
            });
    }

    function download(fileType, data) {
        //transform blob array into a blob of characters
        var blob = new Blob(data, {
            type: fileType === 'csv'
                ? 'text/csv;charset=utf-8;'
                : fileType === 'xlsx'
                  ? 'application/octet-stream'
                  : console.warn('File type not supported: ' + fileType)
        });
        var fileName =
            'webchartsTableExport_' +
            d3.time.format('%Y-%m-%dT%H-%M-%S')(new Date()) +
            '.' +
            fileType;
        var link = this.wrap.select('.export#' + fileType);

        if (navigator.msSaveBlob)
            //IE
            navigator.msSaveBlob(blob, fileName);
        else if (link.node().download !== undefined) {
            //21st century browsers
            var url = URL.createObjectURL(blob);
            link.node().setAttribute('href', url);
            link.node().setAttribute('download', fileName);
        }
    }

    function csv(data) {
        var _this = this;

        this.wrap.select('.export#csv').on('click', function() {
            var CSVarray = [];

            //add headers to CSV array
            var headers = _this.config.headers.map(function(header) {
                return '"' + header.replace(/"/g, '""') + '"';
            });
            CSVarray.push(headers);

            //add rows to CSV array
            data.forEach(function(d, i) {
                var row = _this.config.cols.map(function(col) {
                    var value = d[col];

                    if (typeof value === 'string') value = value.replace(/"/g, '""');

                    return '"' + value + '"';
                });

                CSVarray.push(row);
            });

            //Download .csv file.
            download.call(_this, 'csv', [CSVarray.join('\n')]);
        });
    }

    function xlsx(data) {
        var _this = this;

        this.wrap.select('.export#xlsx').on('click', function() {
            var sheetName = 'Selected Data';
            var options = {
                bookType: 'xlsx',
                bookSST: true,
                type: 'binary'
            };
            var arrayOfArrays = data.map(function(d) {
                return Object.keys(d)
                    .filter(function(key) {
                        return _this.config.cols.indexOf(key) > -1;
                    })
                    .map(function(key) {
                        return d[key];
                    });
            }); // convert data from array of objects to array of arrays.
            var workbook = {
                SheetNames: [sheetName],
                Sheets: {}
            };
            var cols = [];

            //Convert headers and data from array of arrays to sheet.
            workbook.Sheets[sheetName] = XLSX.utils.aoa_to_sheet(
                [_this.config.headers].concat(arrayOfArrays)
            );

            //Add filters to spreadsheet.
            workbook.Sheets[sheetName]['!autofilter'] = {
                ref: 'A1:' + String.fromCharCode(64 + _this.config.cols.length) + (data.length + 1)
            };

            //Define column widths in spreadsheet.
            _this.table.selectAll('thead tr th').each(function() {
                cols.push({ wpx: this.offsetWidth });
            });
            workbook.Sheets[sheetName]['!cols'] = cols;

            var xlsx = XLSX.write(workbook, options);
            var s2ab = function s2ab(s) {
                var buffer = new ArrayBuffer(s.length),
                    view = new Uint8Array(buffer);

                for (var i = 0; i !== s.length; ++i) {
                    view[i] = s.charCodeAt(i) & 0xff;
                }
                return buffer;
            }; // convert spreadsheet to binary or something, i don't know

            //Download .xlsx file.
            download.call(_this, 'xlsx', [s2ab(xlsx)]);
        });
    }

    var exports$1 = {
        csv: csv,
        xlsx: xlsx
    };

    function exportable() {
        return {
            layout: layout$3,
            exports: exports$1
        };
    }

    function layout$4() {
        //Add sort container.
        this.sortable.wrap = this.wrap
            .select('.table-top')
            .append('div')
            .classed('interactivity sortable-container', true)
            .classed('hidden', !this.config.sortable);
        this.sortable.wrap
            .append('div')
            .classed('instruction', true)
            .text('Click column headers to sort.');
    }

    function onClick(th, header) {
        var context = this,
            selection = d3.select(th),
            col = this.config.cols[this.config.headers.indexOf(header)];

        //Check if column is already a part of current sort order.
        var sortItem = this.sortable.order.filter(function(item) {
            return item.col === col;
        })[0];

        //If it isn't, add it to sort order.
        if (!sortItem) {
            sortItem = {
                col: col,
                direction: 'ascending',
                wrap: this.sortable.wrap
                    .append('div')
                    .datum({ key: col })
                    .classed('wc-button sort-box', true)
                    .text(header)
            };
            sortItem.wrap.append('span').classed('sort-direction', true).html('&darr;');
            sortItem.wrap.append('span').classed('remove-sort', true).html('&#10060;');
            this.sortable.order.push(sortItem);
        } else {
            //Otherwise reverse its sort direction.
            sortItem.direction = sortItem.direction === 'ascending' ? 'descending' : 'ascending';
            sortItem.wrap
                .select('span.sort-direction')
                .html(sortItem.direction === 'ascending' ? '&darr;' : '&uarr;');
        }

        //Hide sort instructions.
        this.sortable.wrap.select('.instruction').classed('hidden', true);

        //Add sort container deletion functionality.
        this.sortable.order.forEach(function(item, i) {
            item.wrap.on('click', function(d) {
                //Remove column's sort container.
                d3.select(this).remove();

                //Remove column from sort.
                context.sortable.order.splice(
                    context.sortable.order
                        .map(function(d) {
                            return d.col;
                        })
                        .indexOf(d.key),
                    1
                );

                //Display sorting instruction.
                context.sortable.wrap
                    .select('.instruction')
                    .classed('hidden', context.sortable.order.length);

                //Redraw chart.
                context.draw();
            });
        });

        //Redraw chart.
        this.draw();
    }

    function sortData(data) {
        var _this = this;

        data = data.sort(function(a, b) {
            var order = 0;

            _this.sortable.order.forEach(function(item) {
                var aCell = a[item.col],
                    bCell = b[item.col];

                if (order === 0) {
                    if (
                        (item.direction === 'ascending' && aCell < bCell) ||
                        (item.direction === 'descending' && aCell > bCell)
                    )
                        order = -1;
                    else if (
                        (item.direction === 'ascending' && aCell > bCell) ||
                        (item.direction === 'descending' && aCell < bCell)
                    )
                        order = 1;
                }
            });

            return order;
        });
    }

    function sortable() {
        return {
            layout: layout$4,
            onClick: onClick,
            sortData: sortData,
            order: []
        };
    }

    function layout$5() {
        this.pagination.wrap = this.wrap
            .select('.table-bottom')
            .append('div')
            .classed('interactivity pagination-container', true)
            .classed('hidden', !this.config.pagination);
    }

    function updatePagination() {
        var _this = this;

        //Reset pagination.
        this.pagination.links.classed('active', false);

        //Set to active the selected page link.
        var activePage = this.pagination.links
            .filter(function(link) {
                return +link.rel === +_this.config.activePage;
            })
            .classed('active', true);

        //Define and draw selected page.
        this.config.startIndex = this.config.activePage * this.config.nRowsPerPage;
        this.config.endIndex = this.config.startIndex + this.config.nRowsPerPage;

        //Redraw table.
        this.draw();
    }

    function addLinks() {
        var _this = this;

        //Count rows.

        this.pagination.wrap.selectAll('a,span').remove();

        var _loop = function _loop(i) {
            _this.pagination.wrap
                .append('a')
                .datum({ rel: i })
                .attr({
                    rel: i
                })
                .text(i + 1)
                .classed('wc-button page-link', true)
                .classed('active', function(d) {
                    return d.rel == _this.config.activePage;
                })
                .classed('hidden', function() {
                    return _this.config.activePage < _this.config.nPageLinksDisplayed
                        ? i >= _this.config.nPageLinksDisplayed // first nPageLinksDisplayed pages
                        : _this.config.activePage >=
                              _this.config.nPages - _this.config.nPageLinksDisplayed
                          ? i < _this.config.nPages - _this.config.nPageLinksDisplayed // last nPageLinksDisplayed pages
                          : i <
                                _this.config.activePage -
                                    (Math.ceil(_this.config.nPageLinksDisplayed / 2) - 1) ||
                                _this.config.activePage + _this.config.nPageLinksDisplayed / 2 < i; // nPageLinksDisplayed < activePage or activePage < (nPages - nPageLinksDisplayed)
                });
        };

        for (var i = 0; i < this.config.nPages; i++) {
            _loop(i);
        }

        this.pagination.links = this.pagination.wrap.selectAll('a.page-link');
    }

    function addArrows() {
        var prev = this.config.activePage - 1,
            next = this.config.activePage + 1;
        if (prev < 0) prev = 0; // nothing before the first page
        if (next >= this.config.nPages) next = this.config.nPages - 1; // nothing after the last page

        /**-------------------------------------------------------------------------------------------\
          Left side
        \-------------------------------------------------------------------------------------------**/

        this.pagination.wrap
            .insert('span', ':first-child')
            .classed('dot-dot-dot', true)
            .text('...')
            .classed('hidden', this.config.activePage < this.config.nPageLinksDisplayed);

        this.pagination.prev = this.pagination.wrap
            .insert('a', ':first-child')
            .classed('wc-button arrow-link wc-left', true)
            .classed('hidden', this.config.activePage == 0)
            .attr({
                rel: prev
            })
            .text('<');

        this.pagination.doublePrev = this.pagination.wrap
            .insert('a', ':first-child')
            .classed('wc-button arrow-link wc-left double', true)
            .classed('hidden', this.config.activePage == 0)
            .attr({
                rel: 0
            })
            .text('<<');

        /**-------------------------------------------------------------------------------------------\
          Right side
        \-------------------------------------------------------------------------------------------**/

        this.pagination.wrap
            .append('span')
            .classed('dot-dot-dot', true)
            .text('...')
            .classed(
                'hidden',
                this.config.activePage >=
                    Math.max(
                        this.config.nPageLinksDisplayed,
                        this.config.nPages - this.config.nPageLinksDisplayed
                    ) || this.config.nPages <= this.config.nPageLinksDisplayed
            );
        this.pagination.next = this.pagination.wrap
            .append('a')
            .classed('wc-button arrow-link wc-right', true)
            .classed(
                'hidden',
                this.config.activePage == this.config.nPages - 1 || this.config.nPages == 0
            )
            .attr({
                rel: next
            })
            .text('>');

        this.pagination.doubleNext = this.pagination.wrap
            .append('a')
            .classed('wc-button arrow-link wc-right double', true)
            .classed(
                'hidden',
                this.config.activePage == this.config.nPages - 1 || this.config.nPages == 0
            )
            .attr({
                rel: this.config.nPages - 1
            })
            .text('>>');

        this.pagination.arrows = this.pagination.wrap.selectAll('a.arrow-link');
        this.pagination.doubleArrows = this.pagination.wrap.selectAll('a.double-arrow-link');
    }

    function addPagination(data) {
        var context = this;

        //Calculate number of pages needed and create a link for each page.
        this.config.nRows = data.length;
        this.config.nPages = Math.ceil(this.config.nRows / this.config.nRowsPerPage);

        //hide the pagination if there is only one page
        this.config.paginationHidden = this.config.nPages === 1;
        this.pagination.wrap.classed('hidden', this.config.paginationHidden);

        //Render page links.
        addLinks.call(this);

        //Render a different page on click.
        this.pagination.links.on('click', function() {
            context.config.activePage = +d3.select(this).attr('rel');
            updatePagination.call(context);
        });

        //Render arrow links.
        addArrows.call(this);

        //Render a different page on click.
        this.pagination.arrows.on('click', function() {
            if (context.config.activePage !== +d3.select(this).attr('rel')) {
                context.config.activePage = +d3.select(this).attr('rel');
                context.pagination.prev.attr(
                    'rel',
                    context.config.activePage > 0 ? context.config.activePage - 1 : 0
                );
                context.pagination.next.attr(
                    'rel',
                    context.config.activePage < context.config.nPages
                        ? context.config.activePage + 1
                        : context.config.nPages - 1
                );
                updatePagination.call(context);
            }
        });

        //Render a different page on click.
        this.pagination.doubleArrows.on('click', function() {
            context.config.activePage = +d3.select(this).attr('rel');
            updatePagination.call(context);
        });

        return {
            addLinks: addLinks,
            addArrows: addArrows,
            updatePagination: updatePagination
        };
    }

    function pagination() {
        this.config.nRows = this.data.raw.length; // total number of rows, i.e. the length of the data file
        this.config.nPages = Math.ceil(this.config.nRows / this.config.nRowsPerPage); // total number of pages given number of rows
        this.config.activePage = 0; // current page, 0-indexed
        this.config.startIndex = this.config.activePage * this.config.nRowsPerPage; // first row shown
        this.config.endIndex = this.config.startIndex + this.config.nRowsPerPage; // last row shown
        this.config.paginationHidden = this.config.nPages == 1;
        return {
            layout: layout$5,
            addPagination: addPagination
        };
    }

    function init$2(data) {
        var _this = this;

        var test = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : false;

        this.test = test;

        if (d3.select(this.div).select('.loader').empty()) {
            d3
                .select(this.div)
                .insert('div', ':first-child')
                .attr('class', 'loader')
                .selectAll('.blockG')
                .data(d3.range(8))
                .enter()
                .append('div')
                .attr('class', function(d) {
                    return 'blockG rotate' + (d + 1);
                });
        }

        //Define default settings.
        this.setDefaults.call(this, data[0]);

        //Assign classes to container element.
        this.wrap.classed('wc-chart', true).classed('wc-table', this.config.applyCSS);

        //Define data object.
        this.data = {
            raw: data
        };

        //Attach searchable object to table object.
        this.searchable = searchable.call(this);

        //Attach sortable object to table object.
        this.sortable = sortable.call(this);

        //Attach pagination object to table object.
        this.pagination = pagination.call(this);

        //Attach pagination object to table object.
        this.exportable = exportable.call(this);

        var startup = function startup(data) {
            //connect this table and its controls, if any
            if (_this.controls) {
                _this.controls.targets.push(_this);
                if (!_this.controls.ready) {
                    _this.controls.init(_this.data.raw);
                } else {
                    _this.controls.layout();
                }
            }

            //make sure container is visible (has height and width) before trying to initialize
            var visible = d3.select(_this.div).property('offsetWidth') > 0 || test;
            if (!visible) {
                console.warn(
                    'The table cannot be initialized inside an element with 0 width. The table will be initialized as soon as the container element is given a width > 0.'
                );
                var onVisible = setInterval(function(i) {
                    var visible_now = d3.select(_this.div).property('offsetWidth') > 0;
                    if (visible_now) {
                        _this.layout();
                        _this.wrap.datum(_this);
                        _this.draw();
                        clearInterval(onVisible);
                    }
                }, 500);
            } else {
                _this.layout();
                _this.wrap.datum(_this);
                _this.draw();
            }
        };

        this.events.onInit.call(this);
        if (this.data.raw.length) {
            this.checkRequired(this.data.raw);
        }
        startup(data);

        return this;
    }

    function layout$6() {
        //Clear loading indicator.
        d3.select(this.div).select('.loader').remove();

        //Attach container before table.
        this.wrap.append('div').classed('table-top', true);

        //Attach search container.
        this.searchable.layout.call(this);

        //Attach sort container.
        this.sortable.layout.call(this);

        //Attach table to DOM.
        this.table = this.wrap.append('table').classed('table', this.config.bootstrap); // apply class to incorporate bootstrap styling
        this.thead = this.table.append('thead');
        this.thead.append('tr');
        this.tbody = this.table.append('tbody');

        //Attach container after table.
        this.wrap.append('div').classed('table-bottom', true);

        //Attach pagination container.
        this.pagination.layout.call(this);

        //Attach data export container.
        this.exportable.layout.call(this);

        //Call layout callback.
        this.events.onLayout.call(this);
    }

    function destroy$2() {
        var destroyControls = arguments.length > 0 && arguments[0] !== undefined
            ? arguments[0]
            : false;

        //run onDestroy callback
        this.events.onDestroy.call(this);

        //destroy controls
        if (destroyControls && this.controls) {
            this.controls.destroy();
        }

        //unmount chart wrapper
        this.wrap.remove();
    }

    function setDefault(setting) {
        var _default_ = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : true;

        this.config[setting] = this.config[setting] !== undefined
            ? this.config[setting]
            : _default_;
    }

    function setDefaults$1(firstItem) {
        //Set data-driven defaults.
        if (this.config.cols instanceof Array && this.config.headers instanceof Array) {
            if (this.config.cols.length === 0) delete this.config.cols;
            if (
                this.config.headers.length === 0 ||
                this.config.headers.length !== this.config.cols.length
            )
                delete this.config.headers;
        }

        this.config.cols = this.config.cols || d3.keys(firstItem);
        this.config.headers = this.config.headers || this.config.cols;
        this.config.layout = 'horizontal'; // placeholder setting to align table components vertically or horizontally

        //Set all other defaults.
        setDefault.call(this, 'searchable');
        setDefault.call(this, 'exportable');
        setDefault.call(this, 'exports', ['csv']);
        setDefault.call(this, 'sortable');
        setDefault.call(this, 'pagination');
        setDefault.call(this, 'nRowsPerPage', 10);
        setDefault.call(this, 'nPageLinksDisplayed', 5);
        setDefault.call(this, 'applyCSS');
        setDefault.call(this, 'dynamicPositioning');
    }

    function transformData$1(processed_data) {
        var _this = this;

        //Transform data.
        this.data.processed = this.transformData(this.wrap.datum);

        if (!data) {
            return;
        }

        this.config.cols = this.config.cols || d3.keys(data[0]);
        this.config.headers = this.config.headers || this.config.cols;

        if (this.config.keep) {
            this.config.keep.forEach(function(e) {
                if (_this.config.cols.indexOf(e) === -1) {
                    _this.config.cols.unshift(e);
                }
            });
        }

        var filtered = data;

        if (this.filters.length) {
            this.filters.forEach(function(e) {
                var is_array = e.val instanceof Array;
                filtered = filtered.filter(function(d) {
                    if (is_array) {
                        return e.val.indexOf(d[e.col]) !== -1;
                    } else {
                        return e.val !== 'All' ? d[e.col] === e.val : d;
                    }
                });
            });
        }

        var slimmed = d3
            .nest()
            .key(function(d) {
                if (_this.config.row_per) {
                    return _this.config.row_per
                        .map(function(m) {
                            return d[m];
                        })
                        .join(' ');
                } else {
                    return d;
                }
            })
            .rollup(function(r) {
                if (_this.config.dataManipulate) {
                    r = _this.config.dataManipulate(r);
                }
                var nuarr = r.map(function(m) {
                    var arr = [];
                    for (var x in m) {
                        arr.push({ col: x, text: m[x] });
                    }
                    arr.sort(function(a, b) {
                        return _this.config.cols.indexOf(a.col) - _this.config.cols.indexOf(b.col);
                    });
                    return { cells: arr, raw: m };
                });
                return nuarr;
            })
            .entries(filtered);

        this.data.current = slimmed.length ? slimmed : [{ key: null, values: [] }]; // dummy nested data array

        //Reset pagination.
        this.pagination.wrap.selectAll('*').remove();

        this.events.onDatatransform.call(this);

        /**-------------------------------------------------------------------------------------------\
           Code below associated with the former paradigm of a d3.nest() data array.
        \-------------------------------------------------------------------------------------------**/

        if (config.row_per) {
            var rev_order = config.row_per.slice(0).reverse();
            rev_order.forEach(function(e) {
                tbodies.sort(function(a, b) {
                    return a.values[0].raw[e] - b.values[0].raw[e];
                });
            });
        }

        //Delete text from columns with repeated values?
        if (config.row_per) {
            rows
                .filter(function(f, i) {
                    return i > 0;
                })
                .selectAll('td')
                .filter(function(f) {
                    return config.row_per.indexOf(f.col) > -1;
                })
                .text('');
        }

        return this.data.current;
    }

    var table = Object.create(chart, {
        draw: { value: draw$1 },
        init: { value: init$2 },
        layout: { value: layout$6 },
        setDefaults: { value: setDefaults$1 },
        transformData: { value: transformData$1 },
        destroy: { value: destroy$2 }
    });

    function createTable() {
        var element = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'body';
        var config = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
        var controls = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : null;

        var thisTable = Object.create(table);

        thisTable.div = element;

        thisTable.config = Object.create(config);

        thisTable.controls = controls;

        thisTable.filters = [];

        thisTable.required_cols = [];

        thisTable.wrap = d3.select(thisTable.div).append('div').datum(thisTable);

        thisTable.events = {
            onInit: function onInit() {},
            onLayout: function onLayout() {},
            onPreprocess: function onPreprocess() {},
            onDraw: function onDraw() {},
            onDestroy: function onDestroy() {}
        };

        thisTable.on = function(event, callback) {
            var possible_events = ['init', 'layout', 'preprocess', 'draw', 'destroy'];
            if (possible_events.indexOf(event) < 0) {
                return;
            }
            if (callback) {
                thisTable.events['on' + event.charAt(0).toUpperCase() + event.slice(1)] = callback;
            }
        };

        return thisTable;
    }

    function multiply(chart, data, split_by, order) {
        var test = arguments.length > 4 && arguments[4] !== undefined ? arguments[4] : false;

        chart.wrap.classed('wc-layout wc-small-multiples', true).classed('wc-chart', false);

        //Define container for legend that overrides multiples' legends.
        chart.master_legend = chart.wrap.append('ul').attr('class', 'legend');
        chart.master_legend.append('span').classed('legend-title', true);

        //Instantiate multiples array.
        chart.multiples = [];

        function goAhead(data) {
            var split_vals = d3
                .set(
                    data.map(function(m) {
                        return m[split_by];
                    })
                )
                .values()
                .filter(function(f) {
                    return f;
                });
            if (order) {
                split_vals = split_vals.sort(function(a, b) {
                    return d3.ascending(order.indexOf(a), order.indexOf(b));
                });
            }
            split_vals.forEach(function(e) {
                var mchart = createChart(chart.wrap.node(), chart.config, chart.controls);
                chart.multiples.push(mchart);
                mchart.parent = chart;
                mchart.events = chart.events;
                mchart.legend = chart.master_legend;
                mchart.filters.unshift({ col: split_by, val: e, choices: split_vals });
                mchart.wrap.insert('span', 'svg').attr('class', 'wc-chart-title').text(e);
                mchart.init(data, test);
            });
        }

        goAhead(data);
    }

    function getValType(data, variable) {
        var var_vals = d3
            .set(
                data.map(function(m) {
                    return m[variable];
                })
            )
            .values();
        var vals_numbers = var_vals.filter(function(f) {
            return +f || +f === 0;
        });

        if (var_vals.length === vals_numbers.length && var_vals.length > 4) {
            return 'continuous';
        } else {
            return 'categorical';
        }
    }

    function lengthenRaw(data, columns) {
        var my_data = [];

        data.forEach(function(e) {
            columns.forEach(function(g) {
                var obj = Object.create(e);
                obj.wc_category = g;
                obj.wc_value = e[g];
                my_data.push(obj);
            });
        });

        return my_data;
    }

    var dataOps = {
        getValType: getValType,
        lengthenRaw: lengthenRaw,
        naturalSorter: naturalSorter,
        summarize: summarize
    };

    var index = {
        version: version,
        createChart: createChart,
        createControls: createControls,
        createTable: createTable,
        multiply: multiply,
        dataOps: dataOps
    };

    return index;
});
