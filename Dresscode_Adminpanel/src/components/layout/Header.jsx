import { Search, Bell, User, Menu } from 'lucide-react';

const Header = ({ onMenuClick }) => {
  return (
    <header className="h-16 md:h-20 flex items-center justify-between px-4 md:px-8 bg-zinc-950/90 backdrop-blur-md border-b border-zinc-800 sticky top-0 z-10 gap-4">
      <div className="flex items-center gap-4 flex-1">
        <button 
          onClick={onMenuClick}
          className="lg:hidden text-zinc-400 hover:text-zinc-100 transition-colors p-2 -ml-2"
        >
          <Menu size={24} />
        </button>
        
        <div className="flex-1 max-w-xl relative hidden md:block">
          <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
            <Search size={18} className="text-gray-400" />
          </div>
          <input
            type="text"
            placeholder="Search for anything..."
            className="w-full bg-white border border-gray-200 text-black rounded-full py-2.5 pl-11 pr-4 focus:outline-none focus:ring-2 focus:ring-gold-500/50 focus:border-gold-500/50 transition-all duration-300 placeholder:text-gray-400 shadow-sm"
          />
        </div>
      </div>

      <div className="flex items-center gap-4 md:gap-6">
        <button className="relative text-zinc-400 hover:text-zinc-100 transition-colors">
          <Bell size={22} />
          <span className="absolute 1 top-0 right-0 w-2.5 h-2.5 bg-gold-500 rounded-full border-2 border-zinc-950"></span>
        </button>

        <div className="flex items-center gap-3 cursor-pointer group">
          <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-gold-500 to-gold-500 p-[2px]">
            <div className="w-full h-full rounded-full bg-zinc-900 flex items-center justify-center border-2 border-transparent">
              <User size={18} className="text-zinc-300" />
            </div>
          </div>
          <div className="hidden md:block">
            <p className="text-sm font-medium text-zinc-200 group-hover:text-gold-400 transition-colors">Admin User</p>
            <p className="text-xs text-zinc-500">Superadmin</p>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
