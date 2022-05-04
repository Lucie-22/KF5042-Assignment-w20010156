function data = readLexicon

% READ POSITIVE WORDS 
findPositive = fopen(fullfile('opinion-lexicon-English', 'positive-words.txt'));
C = textscan(findPositive, '%s', 'CommentStyle', ';');
positiveWords = string(C{1});

% READ NEGATIVE WORDS 
findNegative = fopen(fullfile('opinion-lexicon-English', 'negative-words.txt'));
C = textscan(findNegative, '%s', 'CommentStyle', ';');
negativeWords = string(C{1}); 
fclose all;

% Create table of labeled words
words = [positiveWords;negativeWords];
labels = categorical(nan(numel(words),1));
labels(1:numel(positiveWords)) = "Positive";
labels(numel(positiveWords)+1:end) = "Negative";

data = table(words,labels,'VariableNames',{'Word','Label'});

end
