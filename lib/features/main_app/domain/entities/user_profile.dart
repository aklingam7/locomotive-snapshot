import "package:equatable/equatable.dart";

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.creationTime,
  });

  final String uid;
  final String name;
  final DateTime creationTime;

  @override
  List<Object> get props => [uid, name, creationTime];
}
