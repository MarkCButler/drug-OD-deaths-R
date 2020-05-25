library(dplyr)
library(ggplot2)
library(plotly)
library(scales)   # Needed for adding commas to vertical axis labels in ggplot2

# The plots rendered by the server are created using functions defined in this
# file.

# Bring the the function get.column.name and the variables long.curve.labels,
# long.statistic.labels into the current namespace.
source('./global.R')

# Generate a plot showing time development based on the user selection.  The
# argument 'statistic.label' is an element of the vector statistic.labels,
# while the argument 'categories' is a subset of the vector curve.labels.
# Both vectors are defined in global.R
generate.time.plot <- function(data, statistic.label, categories) {
    column.name <- get.column.name(data, statistic.label)

    data <- select(data, Year, Month, Label, one_of(column.name)) %>%
        na.omit() %>%
        filter(Label %in% categories) %>%
        mutate(Label = long.curve.labels[Label]) %>%
        mutate(Date = convert.to.date(paste(Month, Year))) %>%
        select(-Year, -Month)

    # Reorder the legend.labels to match the order given in long.curve.labels.
    legend.labels <- unique(data$Label)
    reordered.indices <- order(match(legend.labels, long.curve.labels))
    ordered.labels <- legend.labels[reordered.indices]

    y.axis.label <- long.statistic.labels[statistic.label]

    if (statistic.label == 'percent.change') {
        label.function <- label_percent
        limits <- NULL
    } else {
        label.function <- label_comma
        limits <- c(0, NA)
    }

    p <- ggplot(data, aes_string(x = 'Date', y = column.name, color = 'Label')) +
        geom_line() +
        geom_point() +
        scale_color_discrete(name = 'Category', breaks = ordered.labels) +
        scale_y_continuous(name = y.axis.label,
                           labels = label.function(accuracy = 1),
                           limits = limits) +
        theme_grey(base_size = 18)

    return(p)
}


# Define variables used in generating the map.  These are defined outside of
# generate.map because the code in these definitions only needs to be executed
# once.

named.state.abbreviations <- setNames(state.abb, state.name)

# Given a choice of statistic, the colorbar range is set to the max and min
# values of that statistic for the dataset.  The colorbar range remains fixed
# when the selected year changed.
colorbar.ranges <- list(death.count = c(55, 5959),
                        normalized.death.count = c(5.9, 55.4),
                        percent.change = c(-.333, .573))

hovertemplates <- c(death.count = '%{z:,d}<br>%{text}<extra></extra>',
                    normalized.death.count = '%{z:.1f}<br>%{text}<extra></extra>',
                    percent.change = '%{z:.2p}<br>%{text}<extra></extra>')

tickformats <- c(death.count = ',d',
                 normalized.death.count = '.0f',
                 percent.change = '.0%')

generate.map <- function(data, statistic.label) {
    column.name <- get.column.name(data, statistic.label)

    # Add state abbreviations for plotly's plot_geo function, and rename the
    # column to be used in coloring the map.  The reason that this renaming is
    # needed is that the column name is currently stored in the variable
    # column.name, but plotly's add_trace function needs the column to be
    # referred to by name, e.g., ~Statistic if Statistic is the column name.
    data <- select(data, State, one_of(column.name)) %>%
        mutate(Code = named.state.abbreviations[State]) %>%
        rename(Statistic = !!column.name)

    colorbar.range <- colorbar.ranges[[statistic.label]]
    hovertemplate <- hovertemplates[statistic.label]
    tickformat <- tickformats[statistic.label]

    map.layout <- list(
        scope = 'usa',
        projection = list(type = 'albers usa')
    )

    hover.annotation <- list(x = 0.5, y = -0.1,
                             text = 'Hover over states to see details',
                             showarrow = F,
                             font = list(size = 16))

    fig <- plot_geo(data, locationmode = 'USA-states') %>%
        add_trace(z = ~Statistic,
                  text = ~State,
                  locations = ~Code,
                  color = ~Statistic,
                  colors = 'RdBu',
                  zmin = colorbar.range[1],
                  zmax = colorbar.range[2],
                  reversescale = T,
                  hovertemplate = hovertemplate) %>%
        colorbar(title = colorbar.titles[statistic.label],
                 tickformat = tickformat) %>%
        layout(geo = map.layout,
               annotations = hover.annotation) %>%
        config(displayModeBar = F, scrollZoom = F)

    return(fig)
}
