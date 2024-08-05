function bootstrapped_vector = bootstrap(vector)
    % Generate random indexes
    indexes = randperm(length(vector));

    % Scramble vector based on random indexes
    bootstrapped_vector = vector(indexes);
end
