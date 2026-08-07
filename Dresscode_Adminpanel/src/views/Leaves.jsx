import React, { useState, useEffect } from 'react';
import { leaveService } from '../services/api';
import { CalendarOff, User, Calendar as CalendarIcon, CheckCircle, Clock, XCircle } from 'lucide-react';

const Leaves = () => {
  const [leaves, setLeaves] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const fetchLeaves = async () => {
    setIsLoading(true);
    try {
      const data = await leaveService.getAll();
      setLeaves(data);
    } catch (error) {
      console.error("Error fetching leaves:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchLeaves();
  }, []);

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric'
    });
  };

  const getStatusBadge = (status) => {
    switch (status?.toLowerCase()) {
      case 'approved':
        return <span className="px-2.5 py-1 text-xs font-medium bg-green-50 text-green-700 border border-green-200 rounded-full flex items-center gap-1 w-fit"><CheckCircle className="w-3 h-3"/> Approved</span>;
      case 'pending':
        return <span className="px-2.5 py-1 text-xs font-medium bg-yellow-50 text-yellow-700 border border-yellow-200 rounded-full flex items-center gap-1 w-fit"><Clock className="w-3 h-3"/> Pending</span>;
      case 'rejected':
        return <span className="px-2.5 py-1 text-xs font-medium bg-red-50 text-red-700 border border-red-200 rounded-full flex items-center gap-1 w-fit"><XCircle className="w-3 h-3"/> Rejected</span>;
      default:
        return <span className="px-2.5 py-1 text-xs font-medium bg-gray-50 text-gray-700 border border-gray-200 rounded-full w-fit capitalize">{status || 'Pending'}</span>;
    }
  };

  return (
    <div className="p-0 md:p-4">
      <div className="mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-black">Leave Requests</h1>
          <p className="text-gray-600 text-sm mt-1">Manage employee leave applications</p>
        </div>
        <button 
          onClick={fetchLeaves}
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
                <th className="px-6 py-4 font-semibold">Employee</th>
                <th className="px-6 py-4 font-semibold">Leave Type</th>
                <th className="px-6 py-4 font-semibold">Duration</th>
                <th className="px-6 py-4 font-semibold">Status</th>
                <th className="px-6 py-4 font-semibold">Applied On</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan="5" className="px-6 py-12 text-center text-gray-500">
                    <div className="flex flex-col items-center justify-center">
                      <div className="w-8 h-8 border-4 border-gold-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                      <p>Loading leave requests...</p>
                    </div>
                  </td>
                </tr>
              ) : leaves.length === 0 ? (
                <tr>
                  <td colSpan="5" className="px-6 py-12 text-center text-gray-500">
                    No leave requests found.
                  </td>
                </tr>
              ) : (
                leaves.map((leave) => (
                  <tr key={leave._id} className="border-b border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-pink-50 flex items-center justify-center text-pink-600 border border-pink-100">
                          <User className="w-5 h-5" />
                        </div>
                        <div>
                          <div className="font-medium text-black">{leave.userId?.name || 'Unknown Employee'}</div>
                          <div className="text-xs text-gray-500 font-mono mt-0.5">ID: {leave.userId?._id?.slice(-6) || leave.userId?.slice?.(-6) || 'N/A'}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="font-medium capitalize text-black">{leave.leaveType || 'Annual'}</span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex flex-col text-gray-600 gap-1">
                        <span className="flex items-center gap-1 text-xs">
                          <CalendarIcon className="w-3 h-3 text-gray-400" /> Start: {formatDate(leave.fromDate)}
                        </span>
                        <span className="flex items-center gap-1 text-xs">
                          <CalendarIcon className="w-3 h-3 text-gray-400" /> End: {formatDate(leave.toDate)}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      {getStatusBadge(leave.status)}
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2 text-gray-600">
                        <CalendarIcon className="w-4 h-4 text-gray-400" />
                        {formatDate(leave.appliedDate || leave.createdAt)}
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

export default Leaves;
