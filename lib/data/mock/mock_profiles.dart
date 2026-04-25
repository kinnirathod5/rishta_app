// lib/data/mock/mock_profiles.dart
// ─────────────────────────────────────────────────────────
// MOCK DATA — Single source of truth
// Phase 3 mein yeh file delete ho jaayegi
// ─────────────────────────────────────────────────────────

class MockProfile {
  final String id;
  final String name;
  final int age;
  final String caste;
  final String city;
  final String profession;
  final String emoji;
  final bool isVerified;
  final bool isPremium;
  final int heightInInches;

  const MockProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.caste,
    required this.city,
    required this.profession,
    required this.emoji,
    required this.isVerified,
    required this.isPremium,
    this.heightInInches = 64,
  });
}

const List<MockProfile> mockProfiles = [
  MockProfile(id: '1',  name: 'Priya Sharma',   age: 26, caste: 'Brahmin',  city: 'Delhi',      profession: 'Software Engineer', emoji: '👩',    isVerified: true,  isPremium: false, heightInInches: 62),
  MockProfile(id: '2',  name: 'Anjali Gupta',   age: 24, caste: 'Kayastha', city: 'Mumbai',     profession: 'Marketing Manager', emoji: '👩‍💼', isVerified: false, isPremium: true,  heightInInches: 60),
  MockProfile(id: '3',  name: 'Meera Singh',    age: 28, caste: 'Rajput',   city: 'Jaipur',     profession: 'Doctor',            emoji: '👩‍⚕️', isVerified: true,  isPremium: true,  heightInInches: 65),
  MockProfile(id: '4',  name: 'Sneha Patel',    age: 25, caste: 'Patel',    city: 'Ahmedabad',  profession: 'CA',                emoji: '👩‍🏫', isVerified: true,  isPremium: false, heightInInches: 61),
  MockProfile(id: '5',  name: 'Ritu Verma',     age: 27, caste: 'Brahmin',  city: 'Lucknow',    profession: 'IIT Graduate',      emoji: '👩‍🔬', isVerified: true,  isPremium: false, heightInInches: 63),
  MockProfile(id: '6',  name: 'Pooja Iyer',     age: 23, caste: 'Iyer',     city: 'Chennai',    profession: 'Dentist',           emoji: '🧑‍⚕️', isVerified: false, isPremium: false, heightInInches: 59),
  MockProfile(id: '7',  name: 'Kavya Reddy',    age: 26, caste: 'Reddy',    city: 'Hyderabad',  profession: 'Data Scientist',    emoji: '👩‍💻', isVerified: true,  isPremium: true,  heightInInches: 64),
  MockProfile(id: '8',  name: 'Nisha Jain',     age: 25, caste: 'Jain',     city: 'Pune',       profession: 'Business',          emoji: '👩‍🚀', isVerified: false, isPremium: false, heightInInches: 62),
  MockProfile(id: '9',  name: 'Arya Nair',      age: 27, caste: 'Nair',     city: 'Kochi',      profession: 'Professor',         emoji: '👩‍🏫', isVerified: true,  isPremium: false, heightInInches: 66),
  MockProfile(id: '10', name: 'Simran Kaur',    age: 24, caste: 'Jat Sikh', city: 'Chandigarh', profession: 'Civil Services',    emoji: '👩‍✈️', isVerified: true,  isPremium: true,  heightInInches: 68),
];