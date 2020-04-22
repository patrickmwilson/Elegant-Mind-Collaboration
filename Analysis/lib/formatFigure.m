function formatFigure(fig, x_lim, y_lim, x_label, y_label, title_text, centerAxes)
    figure(fig);
    xlim(x_lim);
    ylim(y_lim);
    xlabel(x_label);
    ylabel(y_label);
    title(title_text);
    legend('show', 'Location', 'best');
    box on;
    grid on;
    if centerAxes
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
    end
end