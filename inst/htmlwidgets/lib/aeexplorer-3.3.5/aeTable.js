(function(global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined'
        ? (module.exports = factory())
        : typeof define === 'function' && define.amd
          ? define(factory)
          : (global.aeTable = factory());
})(this, function() {
    'use strict';
    /*------------------------------------------------------------------------------------------------\
    Initialize adverse event explorer.
  \------------------------------------------------------------------------------------------------*/

    function init(data) {
        var settings = this.config;

        //create chart wrapper in specified div
        this.wrap = d3.select(this.element).append('div');
        this.wrap.attr('class', 'aeExplorer');

        //save raw data
        this.raw_data = data;

        //settings and defaults
        this.util.setDefaults(this);
        this.layout();

        //Flag placeholder rows in raw data save a separate event-only data set
        var placeholderCol = this.config.defaults.placeholderFlag.value_col;
        var placeholderValues = this.config.defaults.placeholderFlag.values;
        this.raw_data.forEach(function(d) {
            return (d.placeholderFlag = placeholderValues.indexOf(d[placeholderCol]) > -1);
        });
        this.raw_event_data = data.filter(function(d) {
            return !d.placeholderFlag;
        });
        //draw controls and initial chart
        this.controls.init(this);
        this.AETable.redraw(this);
    }

    /*------------------------------------------------------------------------------------------------\
    Set colors.
  \------------------------------------------------------------------------------------------------*/

    var colorScale = d3.scale
        .ordinal()
        .range(['#377EB8', '#4DAF4A', '#984EA3', '#FF7F00', '#A65628', '#F781BF', '#E41A1C']);

    /*------------------------------------------------------------------------------------------------\
    Generate HTML containers.
  \------------------------------------------------------------------------------------------------*/

    function layout() {
        var wrapper = this.wrap
            .append('div')
            .attr('class', 'aeTable')
            .append('div')
            .attr('class', 'table-wrapper');
        wrapper.append('div').attr('class', 'controls');
        wrapper.append('div').attr('class', 'SummaryTable');
        if (this.config.validation)
            this.wrap
                .append('a')
                .attr({
                    id: 'downloadCSV'
                })
                .text('Download Summarized Data');
    }

    /*------------------------------------------------------------------------------------------------\
    Initialize controls.
  \------------------------------------------------------------------------------------------------*/

    function init$1(chart) {
        chart.controls.wrap = chart.wrap.select('div.controls');
        chart.controls.wrap.attr('onsubmit', 'return false;');
        chart.controls.wrap.selectAll('*').remove(); //Clear controls.

        //Draw variable controls if options are specified
        if (chart.config.defaults.useVariableControls) {
            var optionList = ['id', 'major', 'minor', 'group'];
            optionList.forEach(function(option) {
                if (chart.config.variableOptions[option].length > 1) {
                    chart.controls.variableSelect.init(chart, option);
                }
            });
        }

        //Draw standard UI components
        chart.controls.filters.rate.init(chart);
        chart.controls.summaryControl.init(chart);
        chart.controls.search.init(chart);
        chart.controls.filters.custom.init(chart);

        //Initialize the filter rate.
        chart.controls.filters.rate.set(chart);

        //assign filterDiv class to all filter wrappers
        chart.controls.wrap.selectAll('div').classed('filterDiv', true);
    }

    /*------------------------------------------------------------------------------------------------\
    Initialize rate filter.
  \------------------------------------------------------------------------------------------------*/

    function init$2(chart) {
        //create the wrapper
        var selector = chart.controls.wrap.append('div').attr('class', 'rate-filter');

        //Clear rate filter.
        selector.selectAll('span.filterLabel, div.rateFilterDiv').remove();

        //Generate rate filter.
        selector.append('span').attr('class', 'sectionHead').text('Filter by prevalence:');

        var rateFilter = selector
            .append('div')
            .attr('class', 'input-prepend input-append input-medium rateFilterDiv');
        rateFilter.append('span').attr('class', 'add-on before').html('&#8805;');
        rateFilter.append('input').attr({
            class: 'appendedPrependedInput rateFilter',
            type: 'number'
        });
        rateFilter.append('span').attr('class', 'add-on after').text('%');

        //event listener
        rateFilter.on('input', function(d) {
            //Clear filter flags.
            chart.wrap.selectAll('.SummaryTable table tbody tr').classed('filter', false);

            //Add filter flags.
            chart.AETable.toggleRows(chart);
        });
    }

    /*------------------------------------------------------------------------------------------------\
    Set rate filter default.
  \------------------------------------------------------------------------------------------------*/

    function set(chart) {
        chart.controls.wrap
            .select('input.rateFilter')
            .property(
                'value',
                chart.config.defaults.maxPrevalence ? chart.config.defaults.maxPrevalence : 0
            );
    }

    /*------------------------------------------------------------------------------------------------\
    Define rate filter object.
  \------------------------------------------------------------------------------------------------*/

    var rate = {
        init: init$2,
        set: set
    };

    /*------------------------------------------------------------------------------------------------\
    Initialize custom controls.
  \------------------------------------------------------------------------------------------------*/

    //export function init(selector, data, vars, settings) {
    function init$3(chart) {
        //initialize the wrapper
        var selector = chart.controls.wrap.append('div').attr('class', 'custom-filters');

        //add a list of values to each filter object
        chart.config.variables.filters.forEach(function(e) {
            var currentData = e.type == 'participant' ? chart.raw_data : chart.raw_event_data;
            e.values = d3
                .nest()
                .key(function(d) {
                    return d[e.value_col];
                })
                .entries(currentData)
                .map(function(d) {
                    return d.key;
                });
        });

        //drop filters with 0 or 1 levels and throw a warning
        chart.config.variables.filters = chart.config.variables.filters.filter(function(d) {
            if (d.values.length <= 1) {
                console.warn(
                    d.value_col + ' filter not shown since the variable has less than 2 levels'
                );
            }
            return d.values.length > 1;
        });

        //Clear custom controls.
        selector.selectAll('ul.nav').remove();

        //Add filter controls.
        var filterList = selector.append('ul').attr('class', 'nav');
        var filterItem = filterList
            .selectAll('li')
            .data(chart.config.variables.filters)
            .enter()
            .append('li')
            .attr('class', function(d) {
                return 'custom-' + d.key + ' filterCustom';
            });
        var filterLabel = filterItem.append('span').attr('class', 'filterLabel');

        filterLabel.append('span').html(function(d) {
            return d.label || d.value_col;
        });

        filterLabel
            .append('sup')
            .attr('class', 'filterType')
            .text(function(d) {
                return d.type == 'event' ? 'E' : 'P';
            })
            .property('title', function(d) {
                return d.type == 'event'
                    ? 'Event filter: Changes rate counts only. Does not change population.'
                    : 'Participant filter: Changes rate counts and populations.';
            });

        var filterCustom = filterItem.append('select').attr('multiple', true);

        //Add data-driven filter options.
        var filterItems = filterCustom
            .selectAll('option')
            .data(function(d) {
                return d.values.map(function(di) {
                    return {
                        value: di,
                        selected: Array.isArray(d.start) && d.start.length
                            ? d.start.indexOf(di) > -1
                            : true
                    };
                });
            })
            .enter()
            .append('option')
            .html(function(d) {
                return d.value;
            })
            .attr('value', function(d) {
                return d.value;
            })
            .attr('selected', function(d) {
                return d.selected ? 'selected' : null;
            });

        //Initialize event listeners
        filterCustom.on('change', function() {
            chart.AETable.redraw(chart);
        });
    }

    /*------------------------------------------------------------------------------------------------\
    Define custom filters object.
  \------------------------------------------------------------------------------------------------*/

    var custom = { init: init$3 };

    /*------------------------------------------------------------------------------------------------\
    Define filter controls object.
  \------------------------------------------------------------------------------------------------*/

    var filters = {
        rate: rate,
        custom: custom
    };

    /*------------------------------------------------------------------------------------------------\

    Initialize summary control.

  \------------------------------------------------------------------------------------------------*/

    function init$4(chart) {
        //set the initial summary status
        chart.config.summary = chart.config.defaults.summarizeBy;

        //create element
        var selector = chart.controls.wrap.append('div').attr('class', 'summary-control');

        //Clear summary control.
        selector.selectAll('div.summaryDiv').remove();

        //Generate summary control.
        selector.append('span').attr('class', 'sectionHead').text('Summarize by:');

        var summaryControl = selector
            .append('div')
            .attr('class', 'input-prepend input-append input-medium summaryDiv');
        summaryControl
            .selectAll('div')
            .data(['participant', 'event'])
            .enter()
            .append('div')
            .append('label')
            .style('font-weight', function(d) {
                return d === chart.config.summary ? 'bold' : null;
            })
            .text(function(d) {
                return d;
            })
            .append('input')
            .attr({
                class: 'appendedPrependedInput summaryRadio',
                type: 'radio'
            })
            .property('checked', function(d) {
                return d === chart.config.summary;
            });

        //initialize event listener
        var radios = chart.wrap.selectAll('div.summaryDiv .summaryRadio');
        radios.on('change', function(d) {
            radios.each(function(di) {
                d3.select(this.parentNode).style('font-weight', 'normal');
                d3.select(this)[0][0].checked = false;
            });
            d3.select(this)[0][0].checked = true;
            d3.select(this.parentNode).style('font-weight', 'bold');
            chart.config.summary = d3.select(this.parentNode)[0][0].textContent;
            chart.AETable.redraw(chart);
        });
    }

    /*------------------------------------------------------------------------------------------------\
    Define search control object.
  \------------------------------------------------------------------------------------------------*/

    var summaryControl = { init: init$4 };

    function init$5(chart, variable) {
        var selector = chart.controls.wrap.append('div').attr('class', 'variable-control variable');

        //Clear summary control.
        selector.selectAll('div.summaryDiv').remove();

        //Generate summary control.
        var labels = {
            major: 'Major Category Variable:',
            minor: 'Minor Category Variable:',
            group: 'Group Variable:',
            id: 'ID Variable:'
        };
        selector.append('span').attr('class', 'sectionHead').text(labels[variable]);

        var variableControl = selector.append('select');

        variableControl
            .selectAll('option')
            .data(chart.config.variableOptions[variable])
            .enter()
            .append('option')
            .text(function(d) {
                return d;
            })
            .property('selected', function(d) {
                if ((variable == 'group') & !chart.config.defaults.groupCols) {
                    return d == 'None';
                } else {
                    return d === chart.config.variables[variable];
                }
            });

        //initialize event listener
        variableControl.on('change', function(d) {
            var current = this.value;
            if (current != 'None') chart.config.variables[variable] = current;

            //update config.groups if needed
            console.log(chart);
            if (variable == 'group') {
                if (current == 'None') {
                    chart.config.defaults.diffCol = false;
                    chart.config.defaults.groupCols = false;
                    chart.config.defaults.totalCol = true;
                } else {
                    chart.config.defaults.groupCols = true;
                    chart.config.defaults.diffCol = true;
                }

                //update the groups setting
                var allGroups = d3
                    .set(
                        chart.raw_data.map(function(d) {
                            return d[chart.config.variables.group];
                        })
                    )
                    .values();
                var groupsObject = allGroups.map(function(d) {
                    return { key: d };
                });
                chart.config.groups = groupsObject.sort(function(a, b) {
                    return a.key < b.key ? -1 : a.key > b.key ? 1 : 0;
                });

                //update the color scale
                var levels = chart.config.groups.map(function(e) {
                    return e.key;
                });
                var colors = [
                    '#377EB8',
                    '#4DAF4A',
                    '#984EA3',
                    '#FF7F00',
                    '#A65628',
                    '#F781BF',
                    '#E41A1C'
                ];
                if (chart.config.defaults.totalCol)
                    //Set 'Total' column color to #777.
                    colors[chart.config.groups.length] = '#777';

                chart.colorScale.range(colors).domain(levels);
            }

            //Check to see if there are too many levels in the new group variable
            if (
                (chart.config.groups.length > chart.config.defaults.maxGroups) &
                (current != 'None')
            ) {
                chart.wrap
                    .select('.aeTable')
                    .select('.table-wrapper')
                    .select('.SummaryTable')
                    .style('display', 'none');
                var errorText =
                    'Too Many Group Variables specified. You specified ' +
                    chart.config.groups.length +
                    ', but the maximum supported is ' +
                    chart.config.defaults.maxGroups +
                    '.';
                chart.wrap.selectAll('div.wc-alert').remove();
                chart.wrap
                    .append('div')
                    .attr('class', 'wc-alert')
                    .text('Fatal Error: ' + errorText);
                throw new Error(errorText);
            } else {
                chart.wrap
                    .select('.aeTable')
                    .select('.table-wrapper')
                    .select('.SummaryTable')
                    .style('display', null);
                chart.wrap.selectAll('div.wc-alert').remove();
                chart.AETable.redraw(chart);
            }
        });
    }

    /*------------------------------------------------------------------------------------------------\
    Define search control object.
  \------------------------------------------------------------------------------------------------*/

    var variableSelect = { init: init$5 };

    /*------------------------------------------------------------------------------------------------\
    Initialize search control.
  \------------------------------------------------------------------------------------------------*/

    function init$6(chart) {
        //draw the search control
        var selector = chart.controls.wrap
            .append('div')
            .attr('class', 'searchForm wc-navbar-search pull-right')
            .attr('onsubmit', 'return false;');

        //Clear search control.
        selector.selectAll('span.seach-label, input.searchBar').remove();

        //Generate search control.
        var searchLabel = selector.append('span').attr('class', 'search-label label wc-hidden');
        searchLabel.append('span').attr('class', 'search-count');
        searchLabel.append('span').attr('class', 'clear-search').html('&#9747;');
        selector
            .append('input')
            .attr('type', 'text')
            .attr('class', 'searchBar search-query input-medium')
            .attr('placeholder', 'Search');

        //event listeners for search
        chart.wrap.select('input.searchBar').on('input', function(d) {
            var searchTerm = d3.select(this).property('value').toLowerCase();

            if (searchTerm.length > 0) {
                //Clear the previous search but preserve search text.
                chart.controls.search.clear(chart);
                d3.select(this).property('value', searchTerm);

                //Clear flags.
                chart.wrap.selectAll('div.SummaryTable table tbody').classed('minorHidden', false);
                chart.wrap.selectAll('div.SummaryTable table tbody tr').classed('filter', false);
                chart.wrap.select('div.SummaryTable').classed('search', false);
                chart.wrap.selectAll('div.SummaryTable table tbody').classed('search', false);
                chart.wrap.selectAll('div.SummaryTable table tbody tr').classed('search', false);

                //Hide expand/collapse cells.
                chart.wrap
                    .selectAll('div.SummaryTable table tbody tr td.controls span')
                    .classed('wc-hidden', true);

                //Display 'clear search' icon.
                chart.wrap.select('span.search-label').classed('wc-hidden', false);

                //Flag summary table.
                var tab = chart.wrap.select('div.SummaryTable').classed('search', true);

                //Capture rows which contain the search term.
                var tbodyMatch = tab.select('table').selectAll('tbody').each(function(bodyElement) {
                    var bodyCurrent = d3.select(this);
                    var bodyData = bodyCurrent.data()[0];

                    bodyCurrent.selectAll('tr').each(function(rowElement) {
                        var rowCurrent = d3.select(this);
                        var rowData = rowCurrent.data()[0];
                        var rowText = rowCurrent.classed('major')
                            ? bodyData.key.toLowerCase()
                            : rowData.key.toLowerCase();

                        if (rowText.search(searchTerm) >= 0) {
                            bodyCurrent.classed('search', true);
                            rowCurrent.classed('search', true);

                            //Highlight search text in selected table cell.
                            var currentText = rowCurrent.select('td.rowLabel').html();
                            var searchStart = currentText.toLowerCase().search(searchTerm);
                            var searchStop = searchStart + searchTerm.length;
                            var newText =
                                currentText.slice(0, searchStart) +
                                '<span class="search">' +
                                currentText.slice(searchStart, searchStop) +
                                '</span>' +
                                currentText.slice(searchStop, currentText.length);
                            rowCurrent.select('td.rowLabel').html(newText);
                        }
                    });
                });

                //Disable the rate filter.
                d3.select('input.rateFilter').property('disabled', true);

                //Update the search label.
                var matchCount = chart.wrap.selectAll('tr.search')[0].length;
                chart.wrap.select('span.search-count').text(matchCount + ' matches');
                chart.wrap
                    .select('span.search-label')
                    .attr(
                        'class',
                        matchCount === 0
                            ? 'search-label label label-warning'
                            : 'search-label label label-success'
                    );

                //Check whether search term returned zero matches.
                if (matchCount === 0) {
                    //Restore the table.
                    chart.wrap.selectAll('div.SummaryTable').classed('search', false);
                    chart.wrap.selectAll('div.SummaryTable table tbody').classed('search', false);
                    chart.wrap
                        .selectAll('div.SummaryTable table tbody tr')
                        .classed('search', false);

                    //Reset the filters and row toggle.
                    chart.AETable.toggleRows(chart);
                }
            } else chart.controls.search.clear(chart);
        });

        chart.wrap.select('span.clear-search').on('click', function() {
            chart.controls.search.clear(chart);
        });
    }

    /*------------------------------------------------------------------------------------------------\
    Clear search term results.
  \------------------------------------------------------------------------------------------------*/

    function clear(chart) {
        //Re-enable rate filter.
        chart.wrap.select('input.rateFilter').property('disabled', false);

        //Clear search box.
        chart.wrap.select('input.searchBar').property('value', '');

        //Remove search highlighting.
        chart.wrap
            .selectAll('div.SummaryTable table tbody tr.search td.rowLabel')
            .html(function(d) {
                return d.values[0].values['label'];
            });

        //Remove 'clear search' icon and label.
        chart.wrap.select('span.search-label').classed('wc-hidden', true);

        //Clear search flags.
        chart.wrap.selectAll('div.SummaryTable').classed('search', false);
        chart.wrap.selectAll('div.SummaryTable table tbody').classed('search', false);
        chart.wrap.selectAll('div.SummaryTable table tbody tr').classed('search', false);

        //Reset filters and row toggle.
        chart.AETable.toggleRows(chart);
    }

    /*------------------------------------------------------------------------------------------------\
    Define search control object.
  \------------------------------------------------------------------------------------------------*/

    var search = {
        init: init$6,
        clear: clear
    };

    /*------------------------------------------------------------------------------------------------\
    Define controls object.
  \------------------------------------------------------------------------------------------------*/

    var controls = {
        init: init$1,
        filters: filters,
        summaryControl: summaryControl,
        variableSelect: variableSelect,
        search: search
    };

    /*------------------------------------------------------------------------------------------------\
    Clear the current chart and draw a new one.
  \------------------------------------------------------------------------------------------------*/

    function redraw(chart) {
        chart.controls.search.clear(chart);
        chart.AETable.wipe(chart.wrap);
        chart.util.prepareData(chart);
        chart.AETable.init(chart);
        chart.AETable.toggleRows(chart);
    }

    /*------------------------------------------------------------------------------------------------\
    Clears the summary or detail table and all associated buttons.
  \------------------------------------------------------------------------------------------------*/

    function wipe(canvas) {
        canvas.select('.table-wrapper .SummaryTable .wc-alert').remove();
        canvas.select('.table-wrapper .SummaryTable table').remove();
        canvas.select('.table-wrapper .SummaryTable button').remove();
        canvas.select('.table-wrapper .DetailTable').remove();
        canvas.select('.table-wrapper .DetailTable').remove();
    }

    /*------------------------------------------------------------------------------------------------\

    annoteDetails(table, canvas, row, group)
      - Convenience function that shows the raw #s and annotates point values for a single group

          + table
              - AE table object
          + rows
              - highlighted row(s) (selection containing 'tr' objects)
          + group
              - group to highlight

  \------------------------------------------------------------------------------------------------*/

    function showCellCounts(chart, rows, group) {
        //Add raw counts for the specified row/groups .
        rows
            .selectAll('td.values')
            .filter(function(e) {
                return e.key === group;
            })
            .append('span.annote')
            .classed('annote', true)
            .text(function(d) {
                return ' (' + d['values'].n + '/' + d['values'].tot + ')';
            });
    }

    /*------------------------------------------------------------------------------------------------\
    Calculate differences between groups.
  \------------------------------------------------------------------------------------------------*/

    function calculateDifference(major, minor, group1, group2, n1, tot1, n2, tot2) {
        var p1 = n1 / tot1;
        var p2 = n2 / tot2;
        var diff = p1 - p2;
        var se = Math.sqrt(p1 * (1 - p1) / tot1 + p2 * (1 - p2) / tot2);
        var lower = diff - 1.96 * se;
        var upper = diff + 1.96 * se;
        var sig = (lower > 0) | (upper < 0) ? 1 : 0;
        var summary = {
            major: major,
            minor: minor,

            group1: group1,
            n1: n1,
            tot1: tot1,
            p1: p1,

            group2: group2,
            n2: n2,
            tot2: tot2,
            p2: p2,

            diff: diff * 100,
            lower: lower * 100,
            upper: upper * 100,
            sig: sig
        };

        return summary;
    }

    /*------------------------------------------------------------------------------------------------\
    Add differences to data object.
  \------------------------------------------------------------------------------------------------*/

    function addDifferences(data, groups) {
        var nGroups = groups.length;

        if (nGroups > 1) {
            data.forEach(function(major) {
                major.values.forEach(function(minor) {
                    minor.differences = [];

                    var groups = minor.values;
                    var otherGroups = [].concat(minor.values);

                    groups.forEach(function(group) {
                        delete otherGroups[
                            otherGroups
                                .map(function(m) {
                                    return m.key;
                                })
                                .indexOf(group.key)
                        ];
                        otherGroups.forEach(function(otherGroup) {
                            var diff = calculateDifference(
                                major.key,
                                minor.key,
                                group.key,
                                otherGroup.key,
                                group.values.n,
                                group.values.tot,
                                otherGroup.values.n,
                                otherGroup.values.tot
                            );
                            minor.differences.push(diff);
                        });
                    });
                });
            });
        }

        return data;
    }

    /*------------------------------------------------------------------------------------------------\
    Calculate number of events, number of subjects, and adverse event rate by major, minor, and
    group.
  \------------------------------------------------------------------------------------------------*/

    function cross(data, groups, id, major, minor, group) {
        var groupNames = groups.map(function(d) {
            return d.key;
        });
        var summary = d3.selectAll('.summaryDiv label').filter(function(d) {
            return d3.select(this).selectAll('.summaryRadio').property('checked');
        })[0][0].textContent;

        //Calculate [id] and event frequencies and rates by [major], [minor], and [group].
        var nestedData = d3
            .nest()
            .key(function(d) {
                return major == 'All' ? 'All' : d[major];
            })
            .key(function(d) {
                return minor == 'All' ? 'All' : d[minor];
            })
            .key(function(d) {
                return d[group];
            })
            .rollup(function(d) {
                var selection = {};

                //Category
                selection.major = major === 'All' ? 'All' : d[0][major];
                selection.minor = minor === 'All' ? 'All' : d[0][minor];
                selection.label = selection.minor === 'All' ? selection.major : selection.minor;
                selection.group = d[0][group];

                var currentGroup = groups.filter(function(di) {
                    return di.key === d[0][group];
                });

                //Numerator/denominator
                if (summary === 'participant') {
                    var ids = d3
                        .nest()
                        .key(function(di) {
                            return di[id];
                        })
                        .entries(d);
                    selection.n = ids.length;
                    selection.tot = currentGroup[0].n;
                } else {
                    selection.n = d.length;
                    selection.tot = currentGroup[0].nEvents;
                }

                //Rate
                selection.per = Math.round(selection.n / selection.tot * 1000) / 10;

                return selection;
            })
            .entries(data);

        //Generate data objects for major*minor*group combinations absent in data.
        nestedData.forEach(function(dMajor) {
            dMajor.values.forEach(function(dMinor) {
                var currentGroupList = dMinor.values.map(function(d) {
                    return d.key;
                });

                groupNames.forEach(function(dGroup, groupIndex) {
                    if (currentGroupList.indexOf(dGroup) === -1) {
                        var currentGroup = groups.filter(function(d) {
                            return d.key === dGroup;
                        });
                        var tot = summary === 'participant'
                            ? currentGroup[0].n
                            : currentGroup[0].nEvents;

                        var shellMajorMinorGroup = {
                            key: dGroup,
                            values: {
                                major: dMajor.key,
                                minor: dMinor.key,
                                label: dMinor.key === 'All' ? dMajor.key : dMinor.key,
                                group: dGroup,

                                n: 0,
                                tot: tot,
                                per: 0
                            }
                        };

                        dMinor.values.push(shellMajorMinorGroup);
                    }
                });

                dMinor.values.sort(function(a, b) {
                    return (
                        groups
                            .map(function(group) {
                                return group.key;
                            })
                            .indexOf(a.key) -
                        groups
                            .map(function(group) {
                                return group.key;
                            })
                            .indexOf(b.key)
                    );
                });
            });
        });

        return nestedData;
    }

    /*------------------------------------------------------------------------------------------------\
    Define sorting algorithms.
  \------------------------------------------------------------------------------------------------*/

    var sort = {
        //Sort by descending frequency.
        maxPer: function maxPer(a, b) {
            var max_a = a.values.map(function(minor) {
                var n = d3.sum(
                    minor.values.map(function(group) {
                        return group.values.n;
                    })
                );
                var tot = d3.sum(
                    minor.values.map(function(group) {
                        return group.values.tot;
                    })
                );
                return n / tot;
            })[0];
            var max_b = b.values.map(function(minor) {
                var n = d3.sum(
                    minor.values.map(function(group) {
                        return group.values.n;
                    })
                );
                var tot = d3.sum(
                    minor.values.map(function(group) {
                        return group.values.tot;
                    })
                );
                return n / tot;
            })[0];
            var diff = max_b - max_a;

            return diff ? diff : a.key < b.key ? -1 : 1;
        }
    };

    /**-------------------------------------------------------------------------------------------\

    fillrow(currentRow, chart, d)

    inputs (all required):
    currentRow = d3.selector for a 'tr' element
    chart = the chart object
    d = the raw data for the row

      - Convienence function which fills each table row and draws the plots.

        + Note1: We'll call this 3x. Once for the major rows, once for
          the minor rows and once for overall row.

        + Note2: Would be good to split out separate plotting functions if
          this gets too much more complex.

  \-------------------------------------------------------------------------------------------**/

    function fillRow(currentRow, chart, d) {
        var table = chart;
        //Append major row expand/collapse control.
        var controlCell = currentRow.append('td').attr('class', 'controls');

        if (d.key === 'All') {
            controlCell.append('span').attr('title', 'Expand').text('+');
        }

        //Append row label.
        var category = currentRow.append('td').attr({
            class: 'rowLabel',
            title: 'Show listing'
        });
        category.append('a').text(function(rowValues) {
            return rowValues.values[0].values['label'];
        });

        //Calculate total frequency, number of records, population denominator, and rate.
        if (chart.config.defaults.totalCol) {
            var total = {};
            total.major = d.values[0].values.major;
            total.minor = d.values[0].values.minor;
            total.label = d.values[0].values.label;
            total.group = 'Total';

            total.n = d3.sum(d.values, function(di) {
                return di.values.n;
            });
            total.tot = d3.sum(d.values, function(di) {
                return di.values.tot;
            });

            total.per = total.n / total.tot * 100;

            d.values[d.values.length] = {
                key: 'Total',
                values: total
            };
        }

        //Append textual rates.
        var values = currentRow
            .selectAll('td.values')
            .data(d.values, function(d) {
                return d.key;
            })
            .enter()
            .append('td')
            .attr('class', 'values')
            .classed('total', function(d) {
                return d.key == 'Total';
            })
            .classed('wc-hidden', function(d) {
                if (d.key == 'Total') {
                    return !chart.config.defaults.totalCol;
                } else {
                    return !chart.config.defaults.groupCols;
                }
            })
            .attr('title', function(d) {
                return d.values.n + '/' + d.values.tot;
            })
            .text(function(d) {
                return d3.format('0.1f')(d['values'].per) + '%';
            })
            .style('color', function(d) {
                return table.colorScale(d.key);
            });

        //Append graphical rates.
        var prevalencePlot = currentRow
            .append('td')
            .classed('prevplot', true)
            .append('svg')
            .attr('height', chart.config.plotSettings.h)
            .attr('width', chart.config.plotSettings.w + 10)
            .append('svg:g')
            .attr('transform', 'translate(5,0)');

        var points = prevalencePlot
            .selectAll('g.points')
            .data(d.values)
            .enter()
            .append('g')
            .attr('class', 'points');

        points
            .append('svg:circle')
            .attr('cx', function(d) {
                return chart.percentScale(d.values['per']);
            })
            .attr('cy', chart.config.plotSettings.h / 2)
            .attr('r', chart.config.plotSettings.r - 2)
            .attr('fill', function(d) {
                return table.colorScale(d.values['group']);
            })
            .classed('wc-hidden', function(d) {
                if (d.key == 'Total') {
                    return !chart.config.defaults.totalCol;
                } else {
                    return !chart.config.defaults.groupCols;
                }
            })
            .append('title')
            .text(function(d) {
                return d.key + ': ' + d3.format(',.1%')(d.values.per / 100);
            });

        //Handle rate differences between groups if settings reference more then one group.
        if (chart.config.groups.length > 1 && chart.config.defaults.diffCol) {
            //Append container for group rate differences.
            var differencePlot = currentRow
                .append('td')
                .classed('diffplot', true)
                .append('svg')
                .attr('height', chart.config.plotSettings.h)
                .attr('width', chart.config.plotSettings.w + 10)
                .append('svg:g')
                .attr('transform', 'translate(5,0)');

            var diffPoints = differencePlot
                .selectAll('g')
                .data(d.differences)
                .enter()
                .append('svg:g');
            diffPoints.append('title').text(function(d) {
                return (
                    d.group1 +
                    ' (' +
                    d3.format(',.1%')(d.p1) +
                    ') vs. ' +
                    d.group2 +
                    ' (' +
                    d3.format(',.1%')(d.p2) +
                    '): ' +
                    d3.format(',.1%')(d.diff / 100)
                );
            });

            //Append graphical rate difference confidence intervals.
            diffPoints
                .append('svg:line')
                .attr('x1', function(d) {
                    return chart.diffScale(d.upper);
                })
                .attr('x2', function(d) {
                    return chart.diffScale(d.lower);
                })
                .attr('y1', chart.config.plotSettings.h / 2)
                .attr('y2', chart.config.plotSettings.h / 2)
                .attr('class', 'ci')
                .classed('wc-hidden', chart.config.groups.length > 2)
                .attr('stroke', '#bbb');

            //Append graphical rate differences.
            var triangle = d3.svg
                .line()
                .x(function(d) {
                    return d.x;
                })
                .y(function(d) {
                    return d.y;
                })
                .interpolate('linear-closed');

            diffPoints
                .append('svg:path')
                .attr('d', function(d) {
                    var h = chart.config.plotSettings.h,
                        r = chart.config.plotSettings.r;

                    var leftpoints = [
                        { x: chart.diffScale(d.diff), y: h / 2 + r }, //bottom
                        { x: chart.diffScale(d.diff) - r, y: h / 2 }, //middle-left
                        {
                            x: chart.diffScale(d.diff),
                            y: h / 2 - r //top
                        }
                    ];
                    return triangle(leftpoints);
                })
                .attr('class', 'diamond')
                .attr('fill-opacity', function(d) {
                    return d.sig === 1 ? 1 : 0.1;
                })
                .attr('fill', function(d) {
                    return d.diff < 0 ? chart.colorScale(d.group1) : chart.colorScale(d.group2);
                })
                .attr('stroke', function(d) {
                    return d.diff < 0 ? chart.colorScale(d.group1) : chart.colorScale(d.group2);
                })
                .attr('stroke-opacity', 0.3);

            diffPoints
                .append('svg:path')
                .attr('d', function(d) {
                    var h = chart.config.plotSettings.h,
                        r = chart.config.plotSettings.r;

                    var rightpoints = [
                        { x: chart.diffScale(d.diff), y: h / 2 + r }, //bottom
                        { x: chart.diffScale(d.diff) + r, y: h / 2 }, //middle-right
                        {
                            x: chart.diffScale(d.diff),
                            y: h / 2 - r //top
                        }
                    ];
                    return triangle(rightpoints);
                })
                .attr('class', 'diamond')
                .attr('fill-opacity', function(d) {
                    return d.sig === 1 ? 1 : 0.1;
                })
                .attr('fill', function(d) {
                    return d.diff < 0 ? chart.colorScale(d.group2) : chart.colorScale(d.group1);
                })
                .attr('stroke', function(d) {
                    return d.diff < 0 ? chart.colorScale(d.group2) : chart.colorScale(d.group1);
                })
                .attr('stroke-opacity', 0.3);
        }
    }

    /*------------------------------------------------------------------------------------------------\
    Collapse data for export to .csv.
  \------------------------------------------------------------------------------------------------*/

    function collapse(nested) {
        //Collapse nested object.
        var collapsed = nested.map(function(soc) {
            var allRows = soc.values.map(function(e) {
                var eCollapsed = {};
                eCollapsed.majorCategory = e.values[0].values.major;
                eCollapsed.minorCategory = e.values[0].values.minor;

                e.values.forEach(function(val, i) {
                    var n = i + 1;
                    eCollapsed['val' + n + '_label'] = val.key;
                    eCollapsed['val' + n + '_numerator'] = val.values.n;
                    eCollapsed['val' + n + '_denominator'] = val.values.tot;
                    eCollapsed['val' + n + '_percent'] = val.values.per;
                });

                if (e.differences) {
                    e.differences.forEach(function(diff, i) {
                        var n = i + 1;
                        eCollapsed['diff' + n + '_label'] = diff.group1 + '-' + diff.group2;
                        eCollapsed['diff' + n + '_val'] = diff['diff'];
                        eCollapsed['diff' + n + '_sig'] = diff['sig'];
                    });
                }
                return eCollapsed;
            });
            return allRows;
        });
        return d3.merge(collapsed);
    }

    function json2csv(chart) {
        var majorValidation = collapse(chart.data.major),
            // flatten major data array
            minorValidation = collapse(chart.data.minor),
            // flatten minor data array
            fullValidation = d3
                .merge([majorValidation, minorValidation]) // combine flattened major and minor data arrays
                .sort(function(a, b) {
                    return a.majorCategory < b.majorCategory
                        ? -1
                        : a.majorCategory > b.majorCategory
                          ? 1
                          : a.minorCategory < b.minorCategory ? -1 : 1;
                }),
            CSVarray = [];

        fullValidation.forEach(function(d, i) {
            //add headers to CSV array
            if (i === 0) {
                var headers = Object.keys(d).map(function(key) {
                    return '"' + key.replace(/"/g, '""') + '"';
                });
                CSVarray.push(headers);
            }

            //add rows to CSV array
            var row = Object.keys(d).map(function(key) {
                if (typeof d[key] === 'string') d[key] = d[key].replace(/"/g, '""');

                return '"' + d[key] + '"';
            });

            CSVarray.push(row);
        });

        //transform CSV array into CSV string
        var CSV = new Blob([CSVarray.join('\n')], { type: 'text/csv;charset=utf-8;' }),
            fileName =
                chart.config.variables.major +
                '-' +
                chart.config.variables.minor +
                '-' +
                chart.config.summary +
                '.csv',
            link = chart.wrap.select('#downloadCSV');

        if (navigator.msSaveBlob) {
            // IE 10+
            link.style({
                cursor: 'pointer',
                'text-decoration': 'underline',
                color: 'blue'
            });
            link.on('click', function() {
                navigator.msSaveBlob(CSV, fileName);
            });
        } else {
            // Browsers that support HTML5 download attribute
            if (link.node().download !== undefined) {
                // feature detection
                var url = URL.createObjectURL(CSV);
                link.node().setAttribute('href', url);
                link.node().setAttribute('download', fileName);
            }
        }

        return CSVarray;
    }

    /*------------------------------------------------------------------------------------------------\
    Filter the raw data per the current filter and group selections.
    After this function is executed there should be 4 data objects bound to the chart:
    (1) raw_data: an exact copy of the raw data, with an added "placeholderFlag" variable for participants with no events
    (2) raw_event_data: an exact copy of the raw data with placeholder rows removed
    (3) population_data: a copy of the raw data filtered by:
        (a) chart.config.groups - rows from groups not included in the settings object are removed
        (b) charts.config.variables.filters[type=="participant"] - according to current user selections
    (4) population_event_data a copy of the population_data with:
        (a) placeholder rows removed
        (b) filtered by charts.config.variables.filters[type=="participant"] - according to current user selections
  \------------------------------------------------------------------------------------------------*/
    function prepareData(chart) {
        var vars = chart.config.variables; //convenience mapping

        //get filter information
        chart.config.variables.filters.forEach(function(filter_d) {
            //get a list of values that are currently selected
            filter_d.currentValues = [];
            var thisFilter = chart.wrap
                .select('.custom-filters')
                .selectAll('select')
                .filter(function(select_d) {
                    return select_d.value_col == filter_d.value_col;
                });
            thisFilter.selectAll('option').each(function(option_d) {
                if (d3.select(this).property('selected')) {
                    filter_d.currentValues.push(option_d.value);
                }
            });
        });
        /////////////////////////////////
        //Create chart.population_data
        /////////////////////////////////

        //Subset data on groups specified in chart.config.groups.
        var groupNames = chart.config.groups.map(function(d) {
            return d.key;
        });
        chart.population_data = chart.raw_data.filter(function(d) {
            return groupNames.indexOf(d[vars['group']]) >= 0;
        });

        //Filter data to reflect the current population (based on filters where type = `participant`)
        chart.config.variables.filters
            .filter(function(d) {
                return d.type == 'participant';
            })
            .forEach(function(filter_d) {
                //remove the filtered values from the population data
                chart.population_data = chart.population_data.filter(function(rowData) {
                    return filter_d.currentValues.indexOf('' + rowData[filter_d.value_col]) > -1;
                });
            });

        ///////////////////////////////////////
        // create chart.population_event_data
        ////////////////////////////////////////

        // Filter event level data
        chart.population_event_data = chart.population_data.filter(function(d) {
            return !d.placeholderFlag;
        });

        chart.config.variables.filters
            .filter(function(d) {
                return d.type == 'event';
            })
            .forEach(function(filter_d) {
                //remove the filtered values from the population data
                chart.population_event_data = chart.population_event_data.filter(function(rowData) {
                    return filter_d.currentValues.indexOf('' + rowData[filter_d.value_col]) > -1;
                });
            });

        ////////////////////////////////////////////////////////////////////////
        // add group-level participant and event counts to chart.config.groups
        // Used in group headers and to calculate rates
        ////////////////////////////////////////////////////////////////////////

        //Nest data by [vars.group] and [vars.id].
        var nestedData = d3
            .nest()
            .key(function(d) {
                return d[vars.group];
            })
            .key(function(d) {
                return d[vars.id];
            })
            .entries(chart.population_data);

        //Calculate number of participants and number of events for each group.

        chart.config.groups.forEach(function(groupObj) {
            //count unique participants
            var groupVar = chart.config.variables.group;
            var groupValue = groupObj.key;
            var groupEvents = chart.population_data.filter(function(f) {
                return f[groupVar] == groupValue;
            });
            groupObj.n = d3
                .set(
                    groupEvents.map(function(m) {
                        return m[chart.config.variables.id];
                    })
                )
                .values().length;

            //count number of events
            groupObj.nEvents = chart.population_event_data.filter(function(f) {
                return f[groupVar] == groupValue;
            }).length;
        });
    }

    var defaultSettings = {
        variables: {
            id: 'USUBJID',
            major: 'AEBODSYS',
            minor: 'AEDECOD',
            group: 'ARM',
            details: null,
            filters: [
                {
                    value_col: 'AESER',
                    label: 'Serious?',
                    type: 'event',
                    start: null
                },
                {
                    value_col: 'AESEV',
                    label: 'Severity',
                    type: 'event',
                    start: null
                },
                {
                    value_col: 'AEREL',
                    label: 'Relationship',
                    type: 'event',
                    start: null
                },
                {
                    value_col: 'AEOUT',
                    label: 'Outcome',
                    type: 'event',
                    start: null
                }
            ]
        },
        variableOptions: null,
        groups: null,
        defaults: {
            placeholderFlag: {
                value_col: 'AEBODSYS',
                values: ['NA']
            },
            maxPrevalence: 0,
            maxGroups: 6,
            totalCol: true,
            groupCols: true,
            diffCol: true,
            prefTerms: false,
            summarizeBy: 'participant',
            webchartsDetailsTable: false,
            useVariableControls: true
        },
        plotSettings: {
            h: 15,
            w: 200,
            margin: {
                left: 40,
                right: 40
            },
            diffMargin: {
                left: 5,
                right: 5
            },
            r: 7
        },
        validation: false
    };

    /*------------------------------------------------------------------------------------------------\
    Filter the raw data per the current filter and group selections.
  \------------------------------------------------------------------------------------------------*/
    function setDefaults(chart) {
        function errorNote(msg) {
            chart.wrap.append('div').attr('class', 'wc-alert').text('Fatal Error: ' + msg);
        }

        /////////////////////////////
        // Fill defaults as needed //
        /////////////////////////////
        //variables
        chart.config.variables = chart.config.variables || {};

        var variables = ['id', 'major', 'minor', 'group'];
        variables.forEach(function(varName) {
            chart.config.variables[varName] =
                chart.config.variables[varName] || defaultSettings.variables[varName];
        });

        //details, filters and groups
        chart.config.variables.details =
            chart.config.variables.details || defaultSettings.variables.details || [];

        chart.config.variables.filters =
            chart.config.variables.filters || defaultSettings.variables.filters || [];

        chart.config.groups = chart.config.groups || defaultSettings.groups || [];

        //variableOptions
        chart.config.variableOptions =
            chart.config.variableOptions || defaultSettings.variableOptions || {};

        variables.forEach(function(varName) {
            //initialize options for each mapping variable
            chart.config.variableOptions[varName] = chart.config.variableOptions[varName]
                ? chart.config.variableOptions[varName]
                : [];

            //confirm that specified variables are included as options
            var options = chart.config.variableOptions[varName];
            if (options.indexOf(chart.config.variables[varName]) == -1) {
                options.push(chart.config.variables[varName]);
            }

            //add "None" option for group dropdown

            if ((varName == 'group') & (options.indexOf('None') == -1)) {
                options.push('None');
            }
        });

        //defaults
        chart.config.defaults = chart.config.defaults || {};
        var defaults = Object.keys(defaultSettings.defaults);
        defaults.forEach(function(dflt) {
            if (
                dflt !== 'placeholderFlag' // handle primitive types such as maxPrevalence
            )
                chart.config.defaults[dflt] = chart.config.defaults[dflt] !== undefined
                    ? chart.config.defaults[dflt]
                    : defaultSettings.defaults[dflt];
            else {
                // handle objects such as placeholderFlag
                var object = {};
                for (var prop in defaultSettings.defaults[dflt]) {
                    object[prop] = chart.config.defaults[dflt] !== undefined
                        ? chart.config.defaults[dflt][prop] !== undefined
                          ? chart.config.defaults[dflt][prop]
                          : defaultSettings.defaults[dflt][prop]
                        : defaultSettings.defaults[dflt][prop];
                }
                chart.config.defaults[dflt] = object;
            }
        });

        //plot settings
        chart.config.plotSettings = chart.config.plotSettings || {};
        var plotSettings = ['h', 'w', 'r', 'margin', 'diffMargin'];
        plotSettings.forEach(function(varName) {
            chart.config.plotSettings[varName] =
                chart.config.plotSettings[varName] || defaultSettings.plotSettings[varName];
        });

        ////////////////////////////////////////////////////////////
        // Convert group levels from string to objects (if needed)//
        ////////////////////////////////////////////////////////////
        var allGroups = d3
            .set(
                chart.raw_data.map(function(d) {
                    return d[chart.config.variables.group];
                })
            )
            .values();
        chart.config.groups = chart.config.groups
            .map(function(d) {
                return typeof d == 'string' ? { key: d } : d;
            })
            .filter(function(d) {
                if (allGroups.indexOf(d.key) === -1)
                    console.log(
                        'Warning: You specified a group level ("' +
                            d.key +
                            '") that was not found in the data. It is being ignored.'
                    );
                return allGroups.indexOf(d.key) > -1;
            });

        ////////////////////////////////////////////////////
        // Include all group levels if none are specified //
        ////////////////////////////////////////////////////

        var groupsObject = allGroups.map(function(d) {
            return { key: d };
        });

        if (!chart.config.groups || chart.config.groups.length === 0)
            chart.config.groups = groupsObject.sort(function(a, b) {
                return a.key < b.key ? -1 : a.key > b.key ? 1 : 0;
            });

        //////////////////////////////////////////////////////////////
        //Check that variables specified in settings exist in data. //
        //////////////////////////////////////////////////////////////
        for (var x in chart.config.variables) {
            var varList = d3.keys(chart.raw_data[0]).concat('data_all');

            if (varList.indexOf(chart.config.variables[x]) === -1) {
                if (chart.config.variables[x] instanceof Array) {
                    chart.config.variables[x].forEach(function(e) {
                        var value_col = e instanceof Object ? e.value_col : e;
                        if (varList.indexOf(value_col) === -1) {
                            errorNote('Error in variables object.');
                            throw new Error(
                                x + ' variable ' + "('" + e + "') not found in dataset."
                            );
                        }
                    });
                } else {
                    errorNote('Error in variables object.');
                    throw new Error(
                        x +
                            ' variable ' +
                            "('" +
                            chart.config.variables[x] +
                            "') not found in dataset."
                    );
                }
            }
        }

        /////////////////////////////////////////////////////////////////////////////////
        //Checks on group columns (if they're being renderered)                        //
        /////////////////////////////////////////////////////////////////////////////////
        if (chart.config.defaults.groupCols) {
            //Check that group values defined in settings are actually present in dataset. //
            if (
                chart.config.defaults.groupCols &
                (chart.config.groups.length > chart.config.defaults.maxGroups)
            ) {
                var errorText =
                    'Too Many Group Variables specified. You specified ' +
                    chart.config.groups.length +
                    ', but the maximum supported is ' +
                    chart.config.defaults.maxGroups +
                    '.';
                errorNote(errorText);
                throw new Error(errorText);
            }

            //Set the domain for the color scale based on groups. //
            chart.colorScale.domain(
                chart.config.groups.map(function(e) {
                    return e.key;
                })
            );
        }

        //make sure either group or total columns are being renderered
        if (!chart.config.defaults.groupCols & !chart.config.defaults.totalCol) {
            var errorText =
                'No data to render. Make sure at least one of chart.config.defaults.groupCols or chart.config.defaults.totalCol is set to true.';
            errorNote(errorText);
            throw new Error(errorText);
        }

        //don't render differences if you're not renderering group columns
        if (!chart.config.defaults.groupCols) {
            chart.config.defaults.diffCol = false;
        }

        //hide the total column if only one group is selected
        if (chart.config.groups.length == 1) {
            chart.config.defaults.totalCol = false;
        }

        //set color for total column
        if (chart.config.defaults.totalCol)
            //Set 'Total' column color to #777.
            chart.colorScale.range()[chart.config.groups.length] = '#777';
    }

    /*------------------------------------------------------------------------------------------------\
    Define util object.
  \------------------------------------------------------------------------------------------------*/

    var util = {
        calculateDifference: calculateDifference,
        addDifferences: addDifferences,
        cross: cross,
        sort: sort,
        fillRow: fillRow,
        collapse: collapse,
        json2csv: json2csv,
        prepareData: prepareData,
        setDefaults: setDefaults
    };

    /*------------------------------------------------------------------------------------------------\
    Call functions to collapse the raw data using the selected categories and create the summary
    table.
  \------------------------------------------------------------------------------------------------*/

    function init$7(chart) {
        //convinience mappings
        var vars = chart.config.variables;

        /////////////////////////////////////////////////////////////////
        // Prepare the data for charting
        /////////////////////////////////////////////////////////////////
        chart.data = {};

        //Create a dataset nested by [ chart.config.variables.group ] and [ chart.config.variables.id ].
        chart.data.any = util.cross(
            chart.population_event_data,
            chart.config.groups,
            vars['id'],
            'All',
            'All',
            vars['group'],
            chart.config.groups
        );

        //Create a dataset nested by [ chart.config.variables.major ], [ chart.config.variables.group ], and
        //[ chart.config.variables.id ].
        chart.data.major = util.cross(
            chart.population_event_data,
            chart.config.groups,
            vars['id'],
            vars['major'],
            'All',
            vars['group'],
            chart.config.groups
        );

        //Create a dataset nested by [ chart.config.variables.major ], [ chart.config.variables.minor ],
        //[ chart.config.variables.group ], and [ chart.config.variables.id ].
        chart.data.minor = util.cross(
            chart.population_event_data,
            chart.config.groups,
            vars['id'],
            vars['major'],
            vars['minor'],
            vars['group'],
            chart.config.groups
        );

        //Add a 'differences' object to each row.
        chart.data.major = util.addDifferences(chart.data.major, chart.config.groups);
        chart.data.minor = util.addDifferences(chart.data.minor, chart.config.groups);
        chart.data.any = util.addDifferences(chart.data.any, chart.config.groups);

        //Sort the data based by maximum prevelence.
        chart.data.major = chart.data.major.sort(util.sort.maxPer);
        chart.data.minor.forEach(function(major) {
            major.values.sort(function(a, b) {
                var max_a =
                    d3.sum(
                        a.values.map(function(group) {
                            return group.values.n;
                        })
                    ) /
                    d3.sum(
                        a.values.map(function(group) {
                            return group.values.tot;
                        })
                    );
                var max_b =
                    d3.sum(
                        b.values.map(function(group) {
                            return group.values.n;
                        })
                    ) /
                    d3.sum(
                        b.values.map(function(group) {
                            return group.values.tot;
                        })
                    );
                var diff = max_b - max_a;

                return diff ? diff : a.key < b.key ? -1 : 1;
            });
        });

        /////////////////////////////////////////////////////////////////
        // Allow the user to download a csv of the current view
        /////////////////////////////////////////////////////////////////
        //
        //Output the data if the validation setting is flagged.
        if (chart.config.validation) chart.data.CSVarray = util.json2csv(chart);

        /////////////////////////////////////
        // Draw the summary table headers.
        /////////////////////////////////////
        //Check to make sure there is some data
        if (!chart.data.major.length) {
            chart.wrap
                .select('.SummaryTable')
                .append('div')
                .attr('class', 'wc-alert')
                .text(
                    'Error: No AEs found for the current filters. Update the filters to see results.'
                );
            throw new Error('No data found in the column specified for major category. ');
        }

        var tab = chart.wrap.select('.SummaryTable').append('table');
        var nGroups = chart.config.groups.length;
        var header1 = tab.append('thead').append('tr');

        //Expand/collapse control column header
        header1.append('th').attr('rowspan', 2);

        //Category column header
        header1.append('th').attr('rowspan', 2).text('Category');

        //Group column headers
        if (chart.config.defaults.groupCols)
            header1.append('th').attr('colspan', nGroups).text('Groups');

        //Total column header
        if (chart.config.defaults.totalCol) header1.append('th').text('');

        //Graphical AE rates column header
        header1.append('th').text('AE Rate by group');

        //Group differences column header
        var groupHeaders = chart.config.defaults.groupCols ? chart.config.groups : [];
        if (chart.config.defaults.totalCol) {
            groupHeaders = groupHeaders.concat({
                key: 'Total',
                n: d3.sum(chart.config.groups, function(d) {
                    return d.n;
                }),
                nEvents: d3.sum(chart.config.groups, function(d) {
                    return d.nEvents;
                })
            });
        }

        var header2 = tab.select('thead').append('tr');
        header2
            .selectAll('td.values')
            .data(groupHeaders)
            .enter()
            .append('th')
            .html(function(d) {
                return (
                    '<span>' +
                    d.key +
                    '</span>' +
                    '<br><span id="group-num">(n=' +
                    (chart.config.summary === 'participant' ? d.n : d.nEvents) +
                    ')</span>'
                );
            })
            .style('color', function(d) {
                return chart.colorScale(d.key);
            })
            .attr('class', 'values')
            .classed('total', function(d) {
                return d.key == 'Total';
            })
            .classed('wc-hidden', function(d) {
                if (d.key == 'Total') {
                    return !chart.config.defaults.totalCol;
                } else {
                    return !chart.config.defaults.groupCols;
                }
            });
        header2.append('th').attr('class', 'prevHeader');
        if (nGroups > 1 && chart.config.defaults.diffCol) {
            header1.append('th').text('Difference Between Groups').attr('class', 'diffplot');
            header2.append('th').attr('class', 'diffplot axis');
        }

        //Prevalence scales
        var allPercents = d3.merge(
            chart.data.major.map(function(major) {
                return d3.merge(
                    major.values.map(function(minor) {
                        return d3.merge(
                            minor.values.map(function(group) {
                                return [group.values.per];
                            })
                        );
                    })
                );
            })
        );
        chart.percentScale = d3.scale
            .linear()
            .range([0, chart.config.plotSettings.w])
            .range([
                chart.config.plotSettings.margin.left,
                chart.config.plotSettings.w - chart.config.plotSettings.margin.right
            ])
            .domain([0, d3.max(allPercents)]);

        //Add Prevalence Axis
        var percentAxis = d3.svg.axis().scale(chart.percentScale).orient('top').ticks(6);

        var prevAxis = chart.wrap
            .select('th.prevHeader')
            .append('svg')
            .attr('height', '34px')
            .attr('width', chart.config.plotSettings.w + 10)
            .append('svg:g')
            .attr('transform', 'translate(5,34)')
            .attr('class', 'axis percent')
            .call(percentAxis);

        //Difference Scale
        if (chart.config.groups.length > 1) {
            //Difference Scale
            var allDiffs = d3.merge(
                chart.data.major.map(function(major) {
                    return d3.merge(
                        major.values.map(function(minor) {
                            return d3.merge(
                                minor.differences.map(function(diff) {
                                    return [diff.upper, diff.lower];
                                })
                            );
                        })
                    );
                })
            );

            var minorDiffs = d3.merge(
                chart.data.minor.map(function(m) {
                    return d3.merge(
                        m.values.map(function(m2) {
                            return d3.merge(
                                m2.differences.map(function(m3) {
                                    return d3.merge([[m3.upper], [m3.lower]]);
                                })
                            );
                        })
                    );
                })
            );

            chart.diffScale = d3.scale
                .linear()
                .range([
                    chart.config.plotSettings.diffMargin.left,
                    chart.config.plotSettings.w - chart.config.plotSettings.diffMargin.right
                ])
                .domain(d3.extent(d3.merge([minorDiffs, allDiffs])));

            //Difference Axis
            var diffAxis = d3.svg.axis().scale(chart.diffScale).orient('top').ticks(8);

            var prevAxis = chart.wrap
                .select('th.diffplot.axis')
                .append('svg')
                .attr('height', '34px')
                .attr('width', chart.config.plotSettings.w + 10)
                .append('svg:g')
                .attr('transform', 'translate(5,34)')
                .attr('class', 'axis')
                .attr('class', 'percent')
                .call(diffAxis);
        }

        ////////////////////////////
        // Add Rows to the table //
        ////////////////////////////

        //Append a group of rows (<tbody>) for each major category.
        var majorGroups = tab
            .selectAll('tbody')
            .data(chart.data.major, function(d) {
                return d.key;
            })
            .enter()
            .append('tbody')
            .attr('class', 'minorHidden')
            .attr('class', function(d) {
                return 'major-' + d.key.replace(/[^A-Za-z0-9]/g, '');
            });

        //Append a row summarizing all minor categories for each major category.
        var majorRows = majorGroups
            .selectAll('tr')
            .data(
                function(d) {
                    return d.values;
                },
                function(datum) {
                    return datum.key;
                }
            )
            .enter()
            .append('tr')
            .attr('class', 'major')
            .each(function(d) {
                var thisRow = d3.select(this);
                chart.util.fillRow(thisRow, chart, d);
            });

        //Append rows for each minor category.
        var majorGroups = tab.selectAll('tbody').data(chart.data.minor, function(d) {
            return d.key;
        });

        var minorRows = majorGroups
            .selectAll('tr')
            .data(
                function(d) {
                    return d.values;
                },
                function(datum) {
                    return datum.key;
                }
            )
            .enter()
            .append('tr')
            .attr('class', 'minor')
            .each(function(d) {
                var thisRow = d3.select(this);
                chart.util.fillRow(thisRow, chart, d);
            });
        //Add a footer for overall rates.
        tab
            .append('tfoot')
            .selectAll('tr')
            .data(chart.data.any.length > 0 ? chart.data.any[0].values : [])
            .enter()
            .append('tr')
            .each(function(d) {
                var thisRow = d3.select(this);
                chart.util.fillRow(thisRow, chart, d);
            });

        //Remove unwanted elements from the footer.
        tab.selectAll('tfoot svg').remove();
        tab.select('tfoot i').remove();
        tab.select('tfoot td.controls span').text('');

        //////////////////////////////////////////////////
        // Initialize event listeners for summary Table //
        //////////////////////////////////////////////////

        // Show cell counts on Mouseover/Mouseout of difference diamonds
        chart.wrap
            .selectAll('td.diffplot svg g path.diamond')
            .on('mouseover', function(d) {
                var currentRow = chart.wrap.selectAll('.SummaryTable tbody tr').filter(function(e) {
                    return (
                        e.values[0].values.major === d.major && e.values[0].values.minor === d.minor
                    );
                });

                //Display CI;
                d3.select(this.parentNode).select('.ci').classed('wc-hidden', false);

                //show cell counts for selected groups
                showCellCounts(chart, currentRow, d.group1);
                showCellCounts(chart, currentRow, d.group2);
            })
            .on('mouseout', function(d) {
                d3.select(this.parentNode).select('.ci').classed('wc-hidden', true); //hide CI
                chart.wrap.selectAll('.annote').remove(); //Delete annotations.
            });

        // Highlight rows on mouseover
        chart.wrap
            .selectAll('.SummaryTable tr')
            .on('mouseover', function(d) {
                d3.select(this).select('td.rowLabel').classed('highlight', true);
            })
            .on('mouseout', function(d) {
                d3.select(this).select('td.rowLabel').classed('highlight', false);
            });

        //Expand/collapse a section
        chart.wrap.selectAll('tr.major').selectAll('td.controls').on('click', function(d) {
            var current = d3.select(this.parentNode.parentNode);
            var toggle = !current.classed('minorHidden');
            current.classed('minorHidden', toggle);

            d3
                .select(this)
                .select('span')
                .attr('title', toggle ? 'Expand' : 'Collapse')
                .text(function() {
                    return toggle ? '+' : '-';
                });
        });

        // Render the details table
        chart.wrap.selectAll('td.rowLabel').on('click', function(d) {
            //Update classes (row visibility handeled via css)
            var toggle = !chart.wrap.select('.SummaryTable table').classed('summary');
            chart.wrap.select('.SummaryTable table').classed('summary', toggle);
            chart.wrap.select('div.controls').selectAll('div').classed('wc-hidden', toggle);

            //Create/remove the participant level table
            if (toggle) {
                var major = d.values[0].values['major'];
                var minor = d.values[0].values['minor'];
                var detailTableSettings = {
                    major: major,
                    minor: minor
                };
                chart.detailTable.init(chart, detailTableSettings);
            } else {
                chart.wrap.select('.DetailTable').remove();
                chart.wrap.select('div.closeDetailTable').remove();
            }
        });
    }

    /*------------------------------------------------------------------------------------------------\
    Apply basic filters and toggles.
  \------------------------------------------------------------------------------------------------*/

    function toggleRows(chart) {
        //Toggle minor rows.
        var minorToggle = !chart.config.defaults.prefTerms;
        chart.wrap.selectAll('.SummaryTable tbody').classed('minorHidden', minorToggle);
        chart.wrap
            .selectAll('.SummaryTable table tbody')
            .select('tr.major td.controls span')
            .text(minorToggle ? '+' : '-');

        //Toggle Difference plots
        var differenceToggle = false;
        chart.wrap.selectAll('.SummaryTable .diffplot').classed('wc-hidden', differenceToggle);

        //Filter based on prevalence.
        var filterVal = chart.wrap.select('div.controls input.rateFilter').property('value');
        chart.wrap.selectAll('div.SummaryTable table tbody').each(function(d) {
            var allRows = d3.select(this).selectAll('tr');
            var filterRows = allRows.filter(function(d) {
                var percents = d.values
                    .filter(function(d) {
                        //only keep the total column if groupColumns are hidden (otherwise keep all columns)
                        return chart.config.defaults.groupCols ? true : d.key == 'Total';
                    })
                    .map(function(element) {
                        return element.values.per;
                    });
                var maxPercent = d3.max(percents);

                return maxPercent < filterVal;
            });
            filterRows.classed('filter', 'true');

            d3
                .select(this)
                .select('tr.major td.controls span')
                .classed('wc-hidden', filterRows[0].length + 1 >= allRows[0].length);
        });
    }

    /*------------------------------------------------------------------------------------------------\
    Define AETable object (the meat and potatoes).
  \------------------------------------------------------------------------------------------------*/

    var AETable = {
        redraw: redraw,
        wipe: wipe,
        init: init$7,
        toggleRows: toggleRows
    };

    function makeDetailData(chart, detailTableSettings) {
        //convenience mappings
        var major = detailTableSettings.major;
        var minor = detailTableSettings.minor;
        var vars = chart.config.variables;

        //Filter the raw data given the select major and/or minor category.
        var details = chart.population_event_data.filter(function(d) {
            var majorMatch = major === 'All' ? true : major === d[vars['major']];
            var minorMatch = minor === 'All' ? true : minor === d[vars['minor']];
            return majorMatch && minorMatch;
        });

        if (vars.details.length === 0)
            vars.details = Object.keys(chart.population_data[0]).filter(function(d) {
                return ['data_all', 'placeholderFlag'].indexOf(d) === -1;
            });

        //Keep only those columns specified in settings.variables.details append
        //If provided with a details object use that to determine chosen
        //variables and headers
        var detailVars = vars.details;
        var details = details.map(function(d) {
            var current = {};
            detailVars.forEach(function(currentVar) {
                if (currentVar.value_col) {
                    // only true if a details object is provided
                    currentVar.label // if label is provided, write over column name with label
                        ? (current[currentVar.label] = d[currentVar.value_col])
                        : (current[currentVar.value_col] = d[currentVar.value_col]);
                } else {
                    current[currentVar] = d[currentVar];
                }
            });
            return current;
        });

        return details;
    }

    function toggleControls(chart) {
        //Details about current population filters
        var filtered = chart.raw_event_data.length != chart.population_event_data.length;
        if (filtered) {
            chart.wrap
                .select('div.controls')
                .select('div.custom-filters')
                .classed('wc-hidden', false)
                .selectAll('select')
                .property('disabled', 'disabled');
            chart.detailTable.head
                .append('span')
                .html(filtered ? 'The listing is filtered as shown:' : '');
        }
    }

    function makeTitle(chart, detailData, detailTableSettings) {
        //Add explanatory listing title.
        chart.detailTable.head
            .append('h4')
            .html(
                detailTableSettings.minor === 'All'
                    ? 'Details for ' +
                          detailData.length +
                          ' <b>' +
                          detailTableSettings.major +
                          '</b> records'
                    : 'Details for ' +
                          detailData.length +
                          ' <b>' +
                          detailTableSettings.minor +
                          ' (' +
                          detailTableSettings.major +
                          ')</b> records'
            );
    }

    function layout$1(chart) {
        chart.detailTable.wrap = chart.wrap
            .select('div.table-wrapper')
            .append('div')
            .attr('class', 'DetailTable');

        chart.detailTable.head = chart.wrap
            .select('div.table-wrapper')
            .insert('div', '.controls')
            .attr('class', 'DetailHeader');

        //Add button to return to standard view.
        var closeButton = chart.detailTable.head
            .append('button')
            .attr('class', 'closeDetailTable btn btn-primary');

        closeButton.html(
            '<i class="icon-backward icon-white fa fa-backward"></i>    Return to the Summary View'
        );

        closeButton.on('click', function() {
            chart.wrap.select('.SummaryTable table').classed('summary', false);
            chart.wrap.select('div.controls').selectAll('div').classed('wc-hidden', false);
            chart.wrap
                .select('div.controls')
                .select('div.custom-filters')
                .selectAll('select')
                .property('disabled', '');
            chart.wrap.selectAll('.SummaryTable table tbody tr').classed('wc-active', false);
            if (chart.config.defaults.webchartsDetailTable) {
                chart.detailTable.table.destroy();
            }
            chart.detailTable.wrap.remove();
            chart.detailTable.head.remove();
        });
    }

    function draw(chart, data) {
        chart.detailTable.table = webCharts.createTable(
            //chart.config.container + ' .aeExplorer .aeTable .table-wrapper .DetailTable',
            chart.detailTable.wrap.node(),
            {}
        );
        chart.detailTable.table.init(data);
    }

    function draw$1(chart, data) {
        //Generate listing container.
        var canvas = chart.detailTable.wrap;
        var listing = canvas.append('table').attr('class', 'table');

        //Append header to listing container.
        var headerRow = listing.append('thead').append('tr');
        headerRow.selectAll('th').data(d3.keys(data[0])).enter().append('th').html(function(d) {
            return d;
        });

        //Add rows to listing container.
        var tbody = listing.append('tbody');
        var rows = tbody.selectAll('tr').data(data).enter().append('tr');

        //Add data cells to rows.
        var cols = rows
            .selectAll('tr')
            .data(function(d) {
                return d3.values(d);
            })
            .enter()
            .append('td')
            .html(function(d) {
                return d;
            });
    }

    /*------------------------------------------------------------------------------------------------\
    Generate data listing.
  \------------------------------------------------------------------------------------------------*/

    function init$8(chart, detailTableSettings) {
        var detailData = makeDetailData(chart, detailTableSettings);
        layout$1(chart);
        makeTitle(chart, detailData, detailTableSettings);
        toggleControls(chart);

        //initialize and draw the chart either using webcharts or raw D3
        if (chart.config.defaults.webchartsDetailTable) {
            draw(chart, detailData);
        } else {
            draw$1(chart, detailData);
        }
    }

    /*------------------------------------------------------------------------------------------------\
    Define detail table object.
  \------------------------------------------------------------------------------------------------*/

    var detailTable = {
        init: init$8
    };

    function createChart() {
        var element = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'body';
        var config = arguments[1];

        var chart = {
            element: element,
            config: config,
            init: init,
            colorScale: colorScale,
            layout: layout,
            controls: controls,
            AETable: AETable,
            detailTable: detailTable,
            util: util
        };

        return chart;
    }

    var index = {
        createChart: createChart
    };

    return index;
});
