# User Flows

## Core Service Booking Flow

### 1. Job Request Creation
- **User Actions**
  - Sign up/login
    - Email/password or social login
    - Phone number verification
    - Location permission request
  - Create job request
    - Select service category
    - Add detailed description
    - Upload photos (up to 5 photos)
    - Specify preferred timing
  - Location Settings
    - Default radius: 20km
    - Adjustable range: 5km - 50km
    - Manual location adjustment
  - Submit request

- **System Actions**
  - Input Validation
    - Required fields check
    - Photo size/format validation
    - Location verification
  - Provider Search
    - Identify top 10 closest providers
    - Filter by service category
    - Check provider availability
    - Sort by rating and distance
  - Notifications
    - Push notifications to providers
    - Email notifications backup
    - SMS alerts (optional)

### 2. Provider Matching
- **Provider Actions**
  - Receive job alert
    - Push notification
    - In-app notification
    - Job details preview
  - View complete job details
    - Photos and description
    - Customer location
    - Job requirements
  - Communication
    - Initiate in-app chat
    - Request additional photos
    - Discuss requirements
    - Propose site visit timing

- **User Actions**
  - Provider Selection
    - View responding providers
    - Check provider profiles
      - Overall rating
      - Recent reviews
      - Completed jobs
      - Verification status
    - Chat with providers
      - Real-time messaging
      - Photo sharing
      - Location sharing
  - Site Visit
    - Schedule visit times
    - Receive visit confirmation
    - Get provider ETA
    - Site visit reminders

### 3. Quote Acceptance
- **User Actions**
  - Quote Management
    - Receive formal quotes
    - Compare multiple quotes
    - Request quote clarification
    - Quote validity period check
  - Provider Selection
    - Select preferred provider
    - Confirm selection in app
  - Payment Process
    - Review total amount
    - Select payment method
    - Make full payment to escrow
    - Receive payment confirmation

- **System Actions**
  - Payment Processing
    - Validate payment amount
    - Process transaction
    - Hold funds in escrow
    - Generate payment receipt
  - Provider Notification
    - Payment confirmation alert
    - Job acceptance notification
    - Contract generation
  - Job Initialization
    - Create job record
    - Update job status
    - Send confirmations to both parties

### 4. Job Execution
- **Provider Actions**
  - Job Commencement
    - Confirm start date/time
    - Update job status
    - Log progress
    - Report issues/delays
  - Completion
    - Mark tasks complete
    - Upload completion photos
    - Request job completion approval

- **User Actions**
  - Progress Monitoring
    - View job status
    - Communicate with provider
    - Report issues
  - Job Completion
    - Review completed work
    - Confirm satisfaction
    - Approve payment release
    - Report issues (if any)

### 5. Review Process
- **Both Parties**
  - Rating System
    - 1-5 star rating
    - Multiple rating categories
      - Communication
      - Reliability
      - Quality
      - Value
    - Written feedback
    - Photo upload option
  
- **System Actions**
  - Review Processing
    - Validate reviews
    - Update provider ratings
    - Update user ratings
    - Process review notifications
  - Payment Completion
    - Release funds to provider
    - Generate final receipt
    - Close job record

## State Management
### Job States
- CREATED: Initial job posting
- MATCHING: Finding providers
- QUOTED: Quotes received
- ACCEPTED: Provider selected
- PAID: Payment processed
- IN_PROGRESS: Work ongoing
- COMPLETED: Work finished
- REVIEWED: Feedback provided
- CANCELLED: Job cancelled
- DISPUTED: Issue reported

### Payment States
- PENDING: Awaiting payment
- PROCESSED: Payment received
- HELD: In escrow
- RELEASED: Sent to provider
- REFUNDED: Returned to customer
- DISPUTED: Under investigation

## Security Considerations
- Payment Security
  - PCI compliance
  - Secure payment gateway
  - Fraud detection
  - Transaction monitoring
- User Verification
  - ID verification
  - Phone verification
  - Address verification
  - Business registration check
- Data Protection
  - Chat encryption
  - Location data security
  - Photo storage encryption
  - Personal data protection

## Error Handling
- Payment Issues
  - Failed transactions
  - Insufficient funds
  - Payment disputes
  - Refund processing
- Location Services
  - GPS errors
  - Address validation
  - Radius calculation
  - Provider search failures
- Media Handling
  - Upload failures
  - Storage issues
  - Format incompatibility
  - Size limitations
- Communication
  - Message delivery failures
  - Notification errors
  - Chat connection issues
  - Offline handling

## Data Flow Diagrams
[Include flow diagrams here]

## Performance Requirements
- Real-time chat
- Push notifications
- Location services
- Payment processing
- Photo upload/storage

## Error Handling
- Payment failures
- Location errors
- Upload failures
- Network issues
- Notification delivery

## Flow Diagram

```
┌──────────────────┐
│    User Login    │
└────────┬─────────┘
         ▼
┌──────────────────┐
│  Create Job Ad   │
│ ┌──────────────┐ │
│ │Description   │ │
│ │Photos        │ │
│ │Location      │ │
│ │Radius        │ │
└────────┬─────────┘
         ▼
┌──────────────────┐
│ System Process   │
│    ┌─────────┐   │         ┌───────────────┐
│    │Find Top │───┼────────▶│ Notifications │
│    │10 nearby│   │         │   to Service  │
│    │providers│   │         │   Providers   │
│    └─────────┘   │         └───────┬───────┘
└────────┬─────────┘                 │
         │                           ▼
         │                    ┌───────────────┐
         │                    │   Provider    │
         │                    │   Response    │
         │                    └───────┬───────┘
         ▼                           │
┌──────────────────┐                │
│   Chat System    │◀───────────────┘
│ ┌──────────────┐ │
│ │Messages      │ │
│ │Photos        │ │
│ │Scheduling    │ │
└────────┬─────────┘
         ▼
┌──────────────────┐
│   Site Visit     │
│     Quote        │
└────────┬─────────┘
         ▼
┌──────────────────┐
│Quote Acceptance  │◀─────┐
│    Decision      │      │
└────────┬─────────┘      │
         │                │
         │ (No)           │
         └────────────────┘
         │
         │ (Yes)
         ▼
┌──────────────────┐
│  Full Payment    │
│   to ProQuote    │
└────────┬─────────┘
         ▼
┌──────────────────┐
│   Job Starts     │
└────────┬─────────┘
         ▼
┌──────────────────┐
│  Job Completion  │
│  Confirmation    │
└────────┬─────────┘
         ▼
┌──────────────────┐
│ Payment Release  │
│   to Provider    │
└────────┬─────────┘
         ▼
┌──────────────────┐
│ Review Process   │
│ ┌──────────────┐ │
│ │User Review   │ │
│ │Provider Review│ │
└──────────────────┘
``` 