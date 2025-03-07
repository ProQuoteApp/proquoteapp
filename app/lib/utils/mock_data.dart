import 'package:proquote/models/service.dart';
import 'package:proquote/models/provider.dart';
import 'package:proquote/models/job.dart';
import 'package:proquote/models/quote.dart';
import 'package:proquote/models/user.dart';
import 'package:proquote/models/user_profile.dart';

class MockData {
  // Service Categories
  static final List<Map<String, dynamic>> serviceCategories = [
    {
      'id': 'cat1',
      'name': 'Plumbing',
      'icon': 'assets/icons/plumbing.png',
      'color': 0xFF1E88E5,
    },
    {
      'id': 'cat2',
      'name': 'Electrical',
      'icon': 'assets/icons/electrical.png',
      'color': 0xFFFF8F00,
    },
    {
      'id': 'cat3',
      'name': 'Painting',
      'icon': 'assets/icons/painting.png',
      'color': 0xFF43A047,
    },
    {
      'id': 'cat4',
      'name': 'Cleaning',
      'icon': 'assets/icons/cleaning.png',
      'color': 0xFF5E35B1,
    },
    {
      'id': 'cat5',
      'name': 'Gardening',
      'icon': 'assets/icons/gardening.png',
      'color': 0xFF00ACC1,
    },
    {
      'id': 'cat6',
      'name': 'Carpentry',
      'icon': 'assets/icons/carpentry.png',
      'color': 0xFFD81B60,
    },
  ];

  // Services
  static final List<Service> services = [
    Service(
      id: 'serv1',
      name: 'Pipe Repair',
      description: 'Fix leaking pipes and plumbing issues',
      category: 'Plumbing',
      imageUrl: 'https://images.pexels.com/photos/1029635/pexels-photo-1029635.jpeg?auto=compress&cs=tinysrgb&w=600',
      averageRating: 4.7,
      totalRatings: 128,
    ),
    Service(
      id: 'serv2',
      name: 'Electrical Wiring',
      description: 'Install or repair electrical wiring',
      category: 'Electrical',
      imageUrl: 'https://images.pexels.com/photos/3201688/pexels-photo-3201688.jpeg?auto=compress&cs=tinysrgb&w=600',
      averageRating: 4.5,
      totalRatings: 95,
    ),
    Service(
      id: 'serv3',
      name: 'Interior Painting',
      description: 'Paint interior walls and ceilings',
      category: 'Painting',
      imageUrl: 'https://images.pexels.com/photos/6444256/pexels-photo-6444256.jpeg?auto=compress&cs=tinysrgb&w=600',
      averageRating: 4.8,
      totalRatings: 112,
    ),
    Service(
      id: 'serv4',
      name: 'Deep Cleaning',
      description: 'Thorough cleaning of homes and offices',
      category: 'Cleaning',
      imageUrl: 'https://images.pexels.com/photos/4107108/pexels-photo-4107108.jpeg?auto=compress&cs=tinysrgb&w=600',
      averageRating: 4.6,
      totalRatings: 87,
    ),
    Service(
      id: 'serv5',
      name: 'Lawn Maintenance',
      description: 'Regular lawn care and maintenance',
      category: 'Gardening',
      imageUrl: 'https://images.pexels.com/photos/589/garden-grass-meadow-green.jpg?auto=compress&cs=tinysrgb&w=600',
      averageRating: 4.4,
      totalRatings: 76,
    ),
    Service(
      id: 'serv6',
      name: 'Furniture Assembly',
      description: 'Assemble furniture and wooden structures',
      category: 'Carpentry',
      imageUrl: 'https://images.pexels.com/photos/6195085/pexels-photo-6195085.jpeg?auto=compress&cs=tinysrgb&w=600',
      averageRating: 4.9,
      totalRatings: 103,
    ),
  ];

  // Service Providers
  static final List<ServiceProvider> providers = [
    ServiceProvider(
      id: 'prov1',
      name: 'John\'s Plumbing',
      description: 'Professional plumbing services with 15 years of experience',
      profileImageUrl: 'https://images.pexels.com/photos/8961146/pexels-photo-8961146.jpeg?auto=compress&cs=tinysrgb&w=600',
      serviceCategories: ['Plumbing'],
      rating: 4.8,
      completedJobs: 342,
      isVerified: true,
      location: 'Johannesburg, South Africa',
      contactNumber: '+27 82 123 4567',
      email: 'john@plumbing.co.za',
    ),
    ServiceProvider(
      id: 'prov2',
      name: 'ElectriCare',
      description: 'Licensed electricians for all your electrical needs',
      profileImageUrl: 'https://images.pexels.com/photos/8961151/pexels-photo-8961151.jpeg?auto=compress&cs=tinysrgb&w=600',
      serviceCategories: ['Electrical'],
      rating: 4.7,
      completedJobs: 287,
      isVerified: true,
      location: 'Cape Town, South Africa',
      contactNumber: '+27 83 234 5678',
      email: 'info@electricare.co.za',
    ),
    ServiceProvider(
      id: 'prov3',
      name: 'Perfect Painters',
      description: 'Quality painting services for homes and businesses',
      profileImageUrl: 'https://images.pexels.com/photos/8962201/pexels-photo-8962201.jpeg?auto=compress&cs=tinysrgb&w=600',
      serviceCategories: ['Painting'],
      rating: 4.9,
      completedJobs: 198,
      isVerified: true,
      location: 'Durban, South Africa',
      contactNumber: '+27 84 345 6789',
      email: 'info@perfectpainters.co.za',
    ),
    ServiceProvider(
      id: 'prov4',
      name: 'CleanMasters',
      description: 'Professional cleaning services for all spaces',
      profileImageUrl: 'https://images.pexels.com/photos/8961156/pexels-photo-8961156.jpeg?auto=compress&cs=tinysrgb&w=600',
      serviceCategories: ['Cleaning'],
      rating: 4.6,
      completedJobs: 312,
      isVerified: true,
      location: 'Pretoria, South Africa',
      contactNumber: '+27 85 456 7890',
      email: 'info@cleanmasters.co.za',
    ),
    ServiceProvider(
      id: 'prov5',
      name: 'Green Gardens',
      description: 'Expert gardening and landscaping services',
      profileImageUrl: 'https://images.pexels.com/photos/8962124/pexels-photo-8962124.jpeg?auto=compress&cs=tinysrgb&w=600',
      serviceCategories: ['Gardening'],
      rating: 4.5,
      completedJobs: 176,
      isVerified: true,
      location: 'Bloemfontein, South Africa',
      contactNumber: '+27 86 567 8901',
      email: 'info@greengardens.co.za',
    ),
    ServiceProvider(
      id: 'prov6',
      name: 'Woodworks',
      description: 'Custom carpentry and furniture solutions',
      profileImageUrl: 'https://images.pexels.com/photos/8962130/pexels-photo-8962130.jpeg?auto=compress&cs=tinysrgb&w=600',
      serviceCategories: ['Carpentry'],
      rating: 4.9,
      completedJobs: 231,
      isVerified: true,
      location: 'Port Elizabeth, South Africa',
      contactNumber: '+27 87 678 9012',
      email: 'info@woodworks.co.za',
    ),
  ];

  // Jobs
  static final List<Job> jobs = [
    Job(
      id: 'job1',
      title: 'Fix leaking bathroom sink',
      description: 'The bathroom sink has been leaking for a few days. Need someone to fix it as soon as possible.',
      category: 'Plumbing',
      location: 'Sandton, Johannesburg',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      preferredDate: DateTime.now().add(const Duration(days: 3)),
      status: 'open',
      images: [
        'https://images.pexels.com/photos/12271457/pexels-photo-12271457.jpeg?auto=compress&cs=tinysrgb&w=600',
      ],
      userId: 'user1',
      quoteIds: ['quote1', 'quote2'],
    ),
    Job(
      id: 'job2',
      title: 'Install ceiling fan',
      description: 'Need a ceiling fan installed in the living room. The wiring is already in place.',
      category: 'Electrical',
      location: 'Camps Bay, Cape Town',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      preferredDate: DateTime.now().add(const Duration(days: 5)),
      status: 'open',
      images: [
        'https://images.pexels.com/photos/3935316/pexels-photo-3935316.jpeg?auto=compress&cs=tinysrgb&w=600',
      ],
      userId: 'user1',
      quoteIds: ['quote3'],
    ),
    Job(
      id: 'job3',
      title: 'Paint bedroom walls',
      description: 'Looking for someone to paint my bedroom walls. The room is approximately 4m x 5m.',
      category: 'Painting',
      location: 'Umhlanga, Durban',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      preferredDate: DateTime.now().add(const Duration(days: 7)),
      status: 'in_progress',
      images: [
        'https://images.pexels.com/photos/804394/pexels-photo-804394.jpeg?auto=compress&cs=tinysrgb&w=600',
      ],
      userId: 'user1',
      quoteIds: ['quote4', 'quote5'],
    ),
  ];

  // Quotes
  static final List<Quote> quotes = [
    Quote(
      id: 'quote1',
      jobId: 'job1',
      provider: providers[0],
      amount: 850.00,
      description: 'Will fix the leaking sink by replacing the washer and checking for any other issues.',
      estimatedCompletionDate: DateTime.now().add(const Duration(days: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: 'pending',
      includedServices: ['Sink repair', 'Washer replacement', 'Leak check'],
      excludedServices: ['Pipe replacement', 'Sink replacement'],
      includesPartsAndMaterials: true,
    ),
    Quote(
      id: 'quote2',
      jobId: 'job1',
      provider: providers[1],
      amount: 950.00,
      description: 'Complete sink repair service including inspection of all plumbing connections.',
      estimatedCompletionDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      status: 'pending',
      includedServices: ['Sink repair', 'Washer replacement', 'Full plumbing inspection'],
      excludedServices: ['Sink replacement'],
      includesPartsAndMaterials: true,
    ),
    Quote(
      id: 'quote3',
      jobId: 'job2',
      provider: providers[1],
      amount: 1200.00,
      description: 'Installation of ceiling fan including all electrical connections and testing.',
      estimatedCompletionDate: DateTime.now().add(const Duration(days: 6)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: 'accepted',
      includedServices: ['Fan installation', 'Electrical connections', 'Testing'],
      excludedServices: ['Fan purchase', 'Additional wiring'],
      includesPartsAndMaterials: false,
    ),
    Quote(
      id: 'quote4',
      jobId: 'job3',
      provider: providers[2],
      amount: 3500.00,
      description: 'Complete bedroom painting including preparation, priming, and two coats of paint.',
      estimatedCompletionDate: DateTime.now().add(const Duration(days: 8)),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      status: 'accepted',
      includedServices: ['Wall preparation', 'Priming', 'Two coats of paint'],
      excludedServices: ['Ceiling painting', 'Trim painting'],
      includesPartsAndMaterials: true,
    ),
    Quote(
      id: 'quote5',
      jobId: 'job3',
      provider: providers[3],
      amount: 3800.00,
      description: 'Premium painting service with high-quality paints and detailed preparation.',
      estimatedCompletionDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      status: 'rejected',
      includedServices: ['Wall preparation', 'Priming', 'Two coats of premium paint', 'Trim painting'],
      excludedServices: ['Ceiling painting', 'Furniture moving'],
      includesPartsAndMaterials: true,
    ),
  ];

  // Current User
  static final User currentUser = User(
    id: 'user1',
    name: 'Sarah Johnson',
    email: 'sarah.johnson@example.com',
    phoneNumber: '+27 82 987 6543',
    profileImageUrl: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=600',
    address: '123 Main Street, Sandton, Johannesburg',
    jobIds: ['job1', 'job2', 'job3'],
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    userType: UserType.seeker,
    isEmailVerified: true,
    isProfileComplete: true,
  );
} 