import React, { useState, useEffect } from 'react';
import { ordersService } from '../services/api';
import { ClipboardList, User, IndianRupee, Calendar, Info, CheckCircle, Clock, XCircle } from 'lucide-react';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const fetchOrders = async () => {
    setIsLoading(true);
    try {
      const data = await ordersService.getAll();
      setOrders(data);
    } catch (error) {
      console.error("Error fetching orders:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric'
    });
  };

  const getStatusBadge = (status) => {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return <span className="px-2.5 py-1 text-xs font-medium bg-green-50 text-green-700 border border-green-200 rounded-full flex items-center gap-1 w-fit"><CheckCircle className="w-3 h-3"/> {status}</span>;
      case 'pending':
        return <span className="px-2.5 py-1 text-xs font-medium bg-yellow-50 text-yellow-700 border border-yellow-200 rounded-full flex items-center gap-1 w-fit"><Clock className="w-3 h-3"/> Pending</span>;
      case 'cancelled':
        return <span className="px-2.5 py-1 text-xs font-medium bg-red-50 text-red-700 border border-red-200 rounded-full flex items-center gap-1 w-fit"><XCircle className="w-3 h-3"/> Cancelled</span>;
      default:
        return <span className="px-2.5 py-1 text-xs font-medium bg-blue-50 text-blue-700 border border-blue-200 rounded-full w-fit capitalize">{status || 'In Progress'}</span>;
    }
  };

  return (
    <div className="p-0 md:p-4">
      <div className="mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-black">Orders Management</h1>
          <p className="text-gray-600 text-sm mt-1">Track and process customer orders</p>
        </div>
        <button 
          onClick={fetchOrders}
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
                <th className="px-6 py-4 font-semibold">Order Details</th>
                <th className="px-6 py-4 font-semibold">Customer</th>
                <th className="px-6 py-4 font-semibold">Total Cost</th>
                <th className="px-6 py-4 font-semibold">Status</th>
                <th className="px-6 py-4 font-semibold">Event Date</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan="5" className="px-6 py-12 text-center text-gray-500">
                    <div className="flex flex-col items-center justify-center">
                      <div className="w-8 h-8 border-4 border-gold-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                      <p>Loading orders...</p>
                    </div>
                  </td>
                </tr>
              ) : orders.length === 0 ? (
                <tr>
                  <td colSpan="5" className="px-6 py-12 text-center text-gray-500">
                    No orders found in the database.
                  </td>
                </tr>
              ) : (
                orders.map((order) => (
                  <tr key={order._id} className="border-b border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-indigo-50 flex items-center justify-center text-indigo-600 border border-indigo-100">
                          <ClipboardList className="w-5 h-5" />
                        </div>
                        <div>
                          <div className="font-medium text-black">{order.garmentCategory || 'Custom Order'}</div>
                          <div className="text-xs text-gray-500 font-mono mt-0.5">ID: {order._id?.slice(-6)}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <User className="w-4 h-4 text-gray-400" />
                        <div className="flex flex-col">
                          <span className="font-medium">{order.customerName || 'N/A'}</span>
                          <span className="text-xs text-gray-500">{order.customerPhone}</span>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex flex-col">
                        <div className="flex items-center text-black font-bold">
                          <IndianRupee className="w-4 h-4 text-gray-400 mr-1" />
                          {order.totalCost || '0.00'}
                        </div>
                        <span className="text-xs text-gray-500 capitalize">{order.paymentStatus || 'Pending'}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      {getStatusBadge(order.status)}
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2 text-gray-600">
                        <Calendar className="w-4 h-4 text-gray-400" />
                        {formatDate(order.eventDate)}
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

export default Orders;
