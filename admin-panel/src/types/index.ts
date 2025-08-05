export interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  profile_type: 'player' | 'coach' | 'club' | 'team';
  subscription_type: 'free' | 'premium';
  created_at: string;
  is_active: boolean;
  profile_image?: string;
}

export interface SubscriptionPlan {
  id: number;
  name: string;
  type: 'free' | 'premium';
  price: number;
  features: string[];
}

export interface UserFilters {
  search: string;
  profileType: string;
  subscriptionType: string;
  isActive: boolean | null;
} 