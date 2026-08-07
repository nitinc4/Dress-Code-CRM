import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';

const AdminLayout = () => {
  return (
    <div className="flex h-screen bg-zinc-950 overflow-hidden font-sans">
      <Sidebar />
      <div className="flex-1 flex flex-col h-screen overflow-hidden relative">
        {/* Ambient background glow */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 h-64 bg-violet-500/10 blur-[120px] rounded-full pointer-events-none -z-10"></div>
        
        <Header />
        <main className="flex-1 overflow-y-auto p-8 relative z-0">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;
