function logResiduals(data, logfit, N, name, color, csvOutput, logResidualDist)
    figure(logResidualDist);
    
    expected = ((log10(data(:,1))*logfit(1,1))+logfit(1,2));
    residuals = (log10(data(:,2)))-expected;
    
    hold on;
    optN = ceil((sqrt(N))*1.5);
    % Plot histogram of letter height/eccentricity distribution
    histogram(residuals, optN, 'HandleVisibility', 'off',  ...
        'FaceColor', color, 'Normalization', 'probability');
    
    title(sprintf("Log-Log Residuals (%s %s) (%s)", ...
        char(csvOutput{1,3}), name, char(csvOutput{1,4})), 'FontSize', 12);
    xlabel("Residuals");
    ylabel("Number of Occurences (Normalized to Probability)");
    grid on; box on;
    
    [Y,~] = discretize(residuals,optN);
    m = mode(Y);
    gaussHeight = (length(find(Y == m))/N);
    xlim([(min(residuals)*1.2) (max(residuals)*1.2)]);
    ylim([0 (gaussHeight*1.01)]);
end