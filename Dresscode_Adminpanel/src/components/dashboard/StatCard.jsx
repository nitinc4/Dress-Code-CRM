const StatCard = ({ title, value, icon: Icon, trend, trendUp }) => {
  return (
    <div className="p-6 rounded-2xl bg-zinc-900/40 border border-zinc-800/50 backdrop-blur-sm hover:bg-zinc-900/60 transition-all duration-300 group hover:-translate-y-1 hover:shadow-xl hover:shadow-violet-500/5">
      <div className="flex justify-between items-start mb-4">
        <div className="p-3 rounded-xl bg-zinc-800 text-zinc-400 group-hover:text-violet-400 group-hover:bg-violet-500/10 transition-colors">
          <Icon size={22} />
        </div>
        <div className={`flex items-center gap-1 text-sm font-medium px-2.5 py-1 rounded-full ${trendUp ? 'text-emerald-400 bg-emerald-400/10' : 'text-rose-400 bg-rose-400/10'}`}>
          {trendUp ? '↑' : '↓'} {trend}
        </div>
      </div>
      <div>
        <h3 className="text-zinc-400 text-sm font-medium mb-1">{title}</h3>
        <p className="text-3xl font-bold text-zinc-100">{value}</p>
      </div>
    </div>
  );
};

export default StatCard;
