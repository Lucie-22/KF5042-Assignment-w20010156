emb = fastTextWordEmbedding;
data = readLexicon;

idx = data.Label == "Positive";
head(data(idx,:))
idx = data.Label == "Negative";
head(data(idx,:))

% Remove all words that are in the data and not in fastText
idx = ~isVocabularyWord(emb,data.Word);
data(idx,:) = [];

% Set aside 10% of the words at random for testing
numWords = size(data,1);
cvp = cvpartition(numWords,'HoldOut',0.1);
dataTrain = data(training(cvp),:);
dataTest = data(test(cvp),:);

% Convert words in the training data to word vectors using word2vec
wordsTrain = dataTrain.Word;
XTrain = word2vec(emb,wordsTrain);
YTrain = dataTrain.Label;

% Train a support vector machine (SVM) Sentiment Classifier which classifies word vectors into positive and negative categories
model = fitcsvm(XTrain,YTrain);

wordsTest = dataTest.Word;
XTest = word2vec(emb,wordsTest);
YTest = dataTest.Label;

filename = "AnimalCrossingReviews.xlsx"; %"AnimalCrossingReviewsLanguages.xlsx", "StandardReviews.xlsx"
data = readtable(filename, 'TextType', 'string');
textData = data.REVIEW;

% Preprocess the data so that it can be used for analysis
documents = preprocessData(textData);

% Remove words that are in data and not in fastText
idx = ~isVocabularyWord(emb,documents.Vocabulary);
documents = removeWords(documents,idx);

words = documents.Vocabulary;
words(ismember(words, wordsTrain)) = [];

vec = word2vec(emb, words);
[YPred,scores] = predict(model, vec);

% Word Clouds, use to manually check the classifier behaves as expected
figure
subplot(1,2,1)
idx = YPred == "Positive";
wordcloud(words(idx),scores(idx,1));
title("Predicted Positive Sentiment")

subplot(1,2,2)
wordcloud(words(~idx),scores(~idx,2));
title("Predicted Negative Sentiment")

% For each document, convert word to word vectors
% Predict sentiment score on word vectors
% Transform sentiments scores and calculate the mean sentiment score
for i = 1 : numel(documents)
    words = string(documents(i));
    vec = word2vec(emb,words);
    [~,scores] = predict(model,vec);
    sentimentScore(i) = mean(scores(:,1));

    % if sentiment score is to the right or equal to 0.1
    if (sentimentScore(i) >= 0.1)
        sentimentScore(i) = 1; % round sentiment score to 1, POSITIVE REVIEW
    % else if sentiment score is to the left or equal to -0.1
    elseif (sentimentScore(i) <= -0.1) % round sentiment score to -1, NEGATIVE REVIEW
        sentimentScore(i) = -1;
    % else sentiment score is 0
    else
        sentimentScore(i) = 0; % round sentiment score to 0, NEUTRAL REVIEW
    end
end

% Histogram, showcases the sentiment scores of the reviews in a figure
figure(2)
scoreHistogram = categorical(sentimentScore,[-1, 0, 1], {'Negative, -1', 'Neutral, 0', 'Positve, 1'});
histogram(scoreHistogram)
xlabel('Sentiment Score of Reviews')
ylabel('Number of Reviews')
title('Histogram Showcasing the Number of Sentiment Scores of Game Reviews')

% Displays the table as a figure, showcases the sentiment score for each review
scoreTable = table(sentimentScore', textData);
vars = {'Sentiment Score', 'Text Data'};
scoreTableFigure = uifigure;
uitable(scoreTableFigure, 'Data', scoreTable, 'ColumnWidth', {50 500});