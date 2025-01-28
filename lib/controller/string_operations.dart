String getTruncateNameSurname(String fullName, String fullSurname,
    {int maxLength = 17}) {
  String fullNameAndSurname = "$fullName $fullSurname";
  List<String> words = fullNameAndSurname.split(" ");

  if (fullNameAndSurname.length <= maxLength) {
    return fullNameAndSurname.toUpperCase();
  } else if (words.length > 2) {
    return truncateString("${getShortestWord(fullName)} $fullSurname",
            maxLength: maxLength)
        .toUpperCase();
  } else {
    return truncateString(fullNameAndSurname, maxLength: maxLength)
        .toUpperCase();
  }
}

String getTruncateName(String fullName, {int maxLength = 10}) {
  List<String> words = fullName.split(" ");

  if (fullName.length <= maxLength) {
    return fullName.toUpperCase();
  } else if (words.length > 1) {
    return truncateString(words.first, maxLength: maxLength).toUpperCase();
  } else {
    return truncateString(fullName, maxLength: maxLength).toUpperCase();
  }
}

String getTruncateSurname(String fullSurname, {int maxLength = 8}) {
  return truncateString(fullSurname, maxLength: maxLength).toUpperCase();
}

String getFirstAndLastWords(String fullName) {
  List<String> words = fullName.split(" ");
  if (words.length >= 3) {
    return "${words.first} ${words.last}";
  } else {
    return fullName;
  }
}

String truncateString(String input, {int maxLength = 10}) {
  return (input.length > maxLength) ? input.substring(0, maxLength) : input;
}

int countCharacters(String text) {
  return text.length;
}

String getLongestWord(String text) {
  List<String> words = text.split(" ");
  String longWord = "";
  for (String word in words) {
    if (word.length > 6) {
      longWord = word;
    }
  }
  return longWord.isNotEmpty ? longWord : text;
}

String getShortestWord(String text) {
  List<String> words = text.split(" ");
  String shortestWord = words[1];
  for (String word in words) {
    if (word.length < shortestWord.length) {
      shortestWord = word;
    }
  }
  return shortestWord;
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
