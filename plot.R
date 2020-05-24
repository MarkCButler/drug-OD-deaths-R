library(dplyr)
library(ggplot2)
library(plotly)
library(scales)   # Needed for adding commas to vertical axis labels in ggplot2

# The plots used by the server are created using the functions defined in this
# file.

# Bring the the function get.column.name and the variable long.curve.labels
# into the current namespace.
source('./global.R')

# Generate plot showing time development of a selected statistic for a
# selected set of drug-overdose categories.  Here statistic.label is one of
# the elements of the vector statistic.labels, while categories is a subset of
# the vector curve.labels.  Both vectors are defined in global.R
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

        p <- ggplot(data, aes_string(x = 'Date', y = column.name, color = 'Label')) +
            geom_line() +
            geom_point() +
            scale_color_discrete(name = 'Category', breaks = ordered.labels) +
            scale_y_continuous(name = y.axis.label, labels = comma) +
            theme_grey(base_size = 18)

        return(p)
}
