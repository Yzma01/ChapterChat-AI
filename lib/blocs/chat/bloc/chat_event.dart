import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../models/chat_character.dart';

/// Base class for all chat events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load messages for a character
class ChatLoadMessages extends ChatEvent {
  final ChatCharacter character;

  const ChatLoadMessages({required this.character});

  @override
  List<Object?> get props => [character.id];
}

class ClearLocalData extends ChatEvent {
  const ClearLocalData();

  @override
  List<Object?> get props => [];
}

/// Event to send a text message
class ChatSendTextMessage extends ChatEvent {
  final String text;

  const ChatSendTextMessage({required this.text});

  @override
  List<Object?> get props => [text];
}

/// Event to send an image message
class ChatSendImageMessage extends ChatEvent {
  final Uint8List imageBytes;
  final String? caption;

  const ChatSendImageMessage({required this.imageBytes, this.caption});

  @override
  List<Object?> get props => [imageBytes, caption];
}

/// Event when AI response is received
class ChatReceiveResponse extends ChatEvent {
  final String response;

  const ChatReceiveResponse({required this.response});

  @override
  List<Object?> get props => [response];
}

/// Event when AI response fails
class ChatResponseFailed extends ChatEvent {
  final String errorMessage;

  const ChatResponseFailed({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// Event when rate limited
class ChatRateLimited extends ChatEvent {
  final int retryAfterSeconds;

  const ChatRateLimited({required this.retryAfterSeconds});

  @override
  List<Object?> get props => [retryAfterSeconds];
}

/// Event to reset/clear conversation
class ChatResetConversation extends ChatEvent {
  const ChatResetConversation();
}

/// Event to delete a specific message
class ChatDeleteMessage extends ChatEvent {
  final String messageId;

  const ChatDeleteMessage({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

/// Event to update rate limit countdown
class ChatUpdateRateLimitCountdown extends ChatEvent {
  final int secondsRemaining;

  const ChatUpdateRateLimitCountdown({required this.secondsRemaining});

  @override
  List<Object?> get props => [secondsRemaining];
}

/// Event when rate limit expires
class ChatRateLimitExpired extends ChatEvent {
  const ChatRateLimitExpired();
}
