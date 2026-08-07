import { DollarSign, Users, ShoppingBag, Activity, User } from 'lucide-react';
import StatCard from '../components/dashboard/StatCard';

const Dashboard = () => {
  const stats = [
    { title: 'Total Revenue', value: '$45,231.89', icon: DollarSign, trend: '+20.1%', trendUp: true },
    { title: 'Active Users', value: '2,350', icon: Users, trend: '+15.2%', trendUp: true },
    { title: 'New Orders', value: '12,234', icon: ShoppingBag, trend: '+4.5%', trendUp: true },
    { title: 'Bounce Rate', value: '23.4%', icon: Activity, trend: '-2.1%', trendUp: false },
  ];

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
        <h1 className="text-3xl font-bold text-zinc-100">Overview</h1>
        <p className="text-zinc-400 mt-1">Here's what's happening with your store today.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 animate-in fade-in slide-in-from-bottom-8 duration-700">
        {stats.map((stat) => (
          <StatCard key={stat.title} {...stat} />
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 animate-in fade-in slide-in-from-bottom-12 duration-1000">
        <div className="lg:col-span-2 p-6 rounded-2xl bg-zinc-900/40 border border-zinc-800/50 backdrop-blur-sm min-h-[400px]">
          <h2 className="text-xl font-bold text-zinc-100 mb-4">Revenue Overview</h2>
          <div className="w-full h-[300px] flex items-center justify-center border-2 border-dashed border-zinc-800 rounded-xl text-zinc-500">
            [Chart Area Placeholder]
          </div>
        </div>
        <div className="p-6 rounded-2xl bg-zinc-900/40 border border-zinc-800/50 backdrop-blur-sm">
          <h2 className="text-xl font-bold text-zinc-100 mb-4">Recent Activity</h2>
          <div className="space-y-4">
            {[1, 2, 3, 4, 5].map((i) => (
              <div key={i} className="flex items-center gap-4 pb-4 border-b border-zinc-800/50 last:border-0 last:pb-0">
                <div className="w-10 h-10 rounded-full bg-zinc-800 flex items-center justify-center text-zinc-400">
                  <User size={16} />
                </div>
                <div>
                  <p className="text-sm font-medium text-zinc-200">New user registered</p>
                  <p className="text-xs text-zinc-500">2 minutes ago</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
