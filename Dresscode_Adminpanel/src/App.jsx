import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AdminLayout from './components/layout/AdminLayout';
import Dashboard from './views/Dashboard';
import Login from './views/Login';
import Attendances from './views/Attendances';
import Users from './views/Users';
import Products from './views/Products';
import Orders from './views/Orders';
import Inventories from './views/Inventories';
import Customers from './views/Customers';
import Leaves from './views/Leaves';
import ProtectedRoute from './components/ProtectedRoute';
import { AuthProvider } from './context/AuthContext';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          
          <Route element={<ProtectedRoute />}>
            <Route element={<AdminLayout />}>
              <Route path="/" element={<Dashboard />} />
              <Route path="/attendances" element={<Attendances />} />
              <Route path="/users" element={<Users />} />
              <Route path="/products" element={<Products />} />
              <Route path="/orders" element={<Orders />} />
              <Route path="/inventory" element={<Inventories />} />
              <Route path="/customers" element={<Customers />} />
              <Route path="/leaves" element={<Leaves />} />
            </Route>
          </Route>
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
