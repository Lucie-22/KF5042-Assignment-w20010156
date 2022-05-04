% PREPROCESS AND CLEAN DATASET
function documents = preprocessData(textData)

% Tokenize the text
documents = tokenizedDocument(textData);

documents = addPartOfSpeechDetails(documents);

% Remove a list of stop words.
documents = removeStopWords(documents);

% Lemmatise the words
documents = normalizeWords(documents,'Style','lemma');

% Erase the punctuation
documents = erasePunctuation(documents);

% Remove words with 2 or fewer characters, and words with 15 or more
% characters.
documents = removeShortWords(documents, 2);
documents = removeLongWords(documents, 15);

end