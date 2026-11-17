import '../domain/repositories/card_repository.dart';

const unexpectedErrorMessage = 'Something went wrong. Please try again.';
const nameRequiredMessage = 'Enter a card name.';
const valueInvalidMessage = 'Enter a value above 0.';

String messageFor(Object error) => switch (error) {
      CardReadException() =>
        'Your cards could not be loaded. Check the app has storage access '
            'and try again.',
      CardWriteException() => 'Your changes could not be saved. Please try '
          'again.',
      _ => unexpectedErrorMessage,
    };
