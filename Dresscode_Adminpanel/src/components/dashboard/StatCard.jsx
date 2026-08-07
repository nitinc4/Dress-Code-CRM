const StatCard = ({ title, value, icon: Icon, trend, trendUp }) => {
  return (
    <div className="p-6 rounded-2xl bg-white/40 border border-gray-200/50 backdrop-blur-sm hover:bg-white/60 transition-all duration-300 group hover:-translate-y-1 hover:shadow-xl hover:shadow-gold-500/5">
      <div className="flex justify-between items-start mb-4">
        <div className="p-3 rounded-xl bg-gray-100 text-black group-hover:text-gold-400 group-hover:bg-gold-500/10 transition-colors">
          <Icon size={22} />
        </div>
        <div className={`flex items-center gap-1 text-sm font-medium px-2.5 py-1 rounded-full ${trendUp ? 'text-emerald-400 bg-emerald-400/10' : 'text-rose-400 bg-rose-400/10'}`}>
          {trendUp ? '↑' : '↓'} {trend}
        </div>
      </div>
      <div>
        <h3 className="text-black text-sm font-medium mb-1">{title}</h3>
        <p className="text-3xl font-bold text-black">{value}</p>
      </div>
    </div>
  );
};

export default StatCard;
