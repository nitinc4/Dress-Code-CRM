import { LayoutDashboard, Users, ShoppingCart, Settings, LogOut, Clock, X, ClipboardList, Package, UsersRound, CalendarOff } from 'lucide-react';
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const Sidebar = ({ isOpen, setIsOpen }) => {
  const { logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const navItems = [
    { name: 'Dashboard', icon: LayoutDashboard, path: '/' },
    { name: 'Orders', icon: ClipboardList, path: '/orders' },
    { name: 'Products', icon: ShoppingCart, path: '/products' },
    { name: 'Inventory', icon: Package, path: '/inventory' },
    { name: 'Customers', icon: UsersRound, path: '/customers' },
    { name: 'Users', icon: Users, path: '/users' },
    { name: 'Attendances', icon: Clock, path: '/attendances' },
    { name: 'Leaves', icon: CalendarOff, path: '/leaves' },
    { name: 'Settings', icon: Settings, path: '/settings' },
  ];

  return (
    <>
      {/* Mobile overlay */}
      <div 
        className={`fixed inset-0 bg-black/50 z-40 lg:hidden transition-opacity duration-300 ${isOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'}`} 
        onClick={() => setIsOpen(false)} 
      />

      <aside className={`w-64 h-screen flex flex-col bg-zinc-950 border-r border-zinc-800 transition-transform duration-300 fixed lg:relative z-50 lg:translate-x-0 ${isOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <div className="p-6 flex items-center justify-between">
          <h1 className="text-xl font-bold bg-gradient-to-r from-gold-400 to-gold-400 bg-clip-text text-transparent flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-gold-500 to-gold-600 flex items-center justify-center text-black">
              <LayoutDashboard size={18} />
            </div>
            DressCode
          </h1>
          <button className="lg:hidden text-zinc-400 hover:text-zinc-100" onClick={() => setIsOpen(false)}>
            <X size={24} />
          </button>
        </div>

      <nav className="flex-1 px-4 py-6 space-y-2 overflow-y-auto">
        {navItems.map((item) => (
          <NavLink
            key={item.name}
            to={item.path}
            onClick={() => setIsOpen(false)}
            className={({ isActive }) => `flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group ${
              isActive 
                ? 'bg-gold-500/10 text-gold-400 border border-gold-500/20 shadow-[0_0_15px_rgba(234,179,8,0.1)]' 
                : 'text-zinc-400 hover:text-zinc-100 hover:bg-zinc-900'
            }`}
          >
            {({ isActive }) => (
              <>
                <item.icon size={20} className={isActive ? 'text-gold-400' : 'group-hover:text-zinc-100'} />
                <span className="font-medium">{item.name}</span>
              </>
            )}
          </NavLink>
        ))}
      </nav>

      <div className="p-4 mt-auto border-t border-zinc-800">
        <button 
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-3 w-full rounded-xl text-zinc-400 hover:text-red-400 hover:bg-red-400/10 transition-all duration-200"
        >
          <LogOut size={20} />
          <span className="font-medium">Logout</span>
        </button>
      </div>
    </aside>
    </>
  );
};

export default Sidebar;
