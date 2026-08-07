import React, { useState, useEffect } from 'react';
import { usersService } from '../services/api';
import { User as UserIcon, Calendar, Phone, Shield, CheckCircle, XCircle } from 'lucide-react';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const fetchUsers = async () => {
    setIsLoading(true);
    try {
      const data = await usersService.getAll();
      setUsers(data);
    } catch (error) {
      console.error("Error fetching users:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric'
    });
  };

  const getStatusBadge = (status) => {
    switch (status?.toLowerCase()) {
      case 'active':
        return <span className="px-2.5 py-1 text-xs font-medium bg-green-50 text-green-700 border border-green-200 rounded-full flex items-center gap-1 w-fit"><CheckCircle className="w-3 h-3"/> Active</span>;
      case 'inactive':
        return <span className="px-2.5 py-1 text-xs font-medium bg-gray-50 text-gray-700 border border-gray-200 rounded-full flex items-center gap-1 w-fit"><XCircle className="w-3 h-3"/> Inactive</span>;
      default:
        return <span className="px-2.5 py-1 text-xs font-medium bg-gray-50 text-gray-700 border border-gray-200 rounded-full w-fit capitalize">{status || 'Unknown'}</span>;
    }
  };

  const getRoleBadge = (role) => {
    switch (role?.toLowerCase()) {
      case 'admin':
        return <span className="px-2.5 py-1 text-xs font-medium bg-gold-50 text-gold-700 border border-gold-200 rounded-full">Admin</span>;
      case 'sales_rep':
        return <span className="px-2.5 py-1 text-xs font-medium bg-blue-50 text-blue-700 border border-blue-200 rounded-full">Sales Rep</span>;
      case 'customer':
        return <span className="px-2.5 py-1 text-xs font-medium bg-purple-50 text-purple-700 border border-purple-200 rounded-full">Customer</span>;
      default:
        return <span className="px-2.5 py-1 text-xs font-medium bg-gray-50 text-gray-700 border border-gray-200 rounded-full capitalize">{role || 'User'}</span>;
    }
  };

  return (
    <div className="p-0 md:p-4">
      <div className="mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-black">Users Management</h1>
          <p className="text-gray-600 text-sm mt-1">View and manage all registered users in the CRM</p>
        </div>
        <button 
          onClick={fetchUsers}
          className="px-4 py-2 bg-white text-black rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors text-sm font-medium shadow-sm"
        >
          Refresh Data
        </button>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-black">
            <thead className="text-xs uppercase bg-gray-50 text-gray-600 border-b border-gray-200">
              <tr>
                <th className="px-6 py-4 font-semibold">User</th>
                <th className="px-6 py-4 font-semibold">Contact</th>
                <th className="px-6 py-4 font-semibold">Role</th>
                <th className="px-6 py-4 font-semibold">Status</th>
                <th className="px-6 py-4 font-semibold">Joined Date</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan="5" className="px-6 py-12 text-center text-gray-500">
                    <div className="flex flex-col items-center justify-center">
                      <div className="w-8 h-8 border-4 border-gold-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                      <p>Loading users...</p>
                    </div>
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan="5" className="px-6 py-12 text-center text-gray-500">
                    No users found in the database.
                  </td>
                </tr>
              ) : (
                users.map((user) => (
                  <tr key={user._id} className="border-b border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-gold-50 flex items-center justify-center text-gold-600 border border-gold-100">
                          <UserIcon className="w-5 h-5" />
                        </div>
                        <div>
                          <div className="font-medium text-black">{user.name || 'Unnamed User'}</div>
                          <div className="text-xs text-gray-500 font-mono mt-0.5">ID: {user._id.slice(-6)}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <Phone className="w-4 h-4 text-gray-400" />
                        <span>{user.phone || 'N/A'}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <Shield className="w-4 h-4 text-gray-400" />
                        {getRoleBadge(user.role)}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      {getStatusBadge(user.status)}
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2 text-gray-600">
                        <Calendar className="w-4 h-4 text-gray-400" />
                        {formatDate(user.createdAt)}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Users;
