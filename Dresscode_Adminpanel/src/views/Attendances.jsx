import React, { useState, useEffect } from 'react';
import { attendanceService } from '../services/api';
import UpdateAttendanceModal from '../components/UpdateAttendanceModal';
import { Calendar, Clock, MapPin, Edit2, CheckCircle, XCircle } from 'lucide-react';

const Attendances = () => {
  const [attendances, setAttendances] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedAttendance, setSelectedAttendance] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const fetchAttendances = async () => {
    setIsLoading(true);
    try {
      const data = await attendanceService.getAll();
      setAttendances(data);
    } catch (error) {
      console.error("Error fetching attendances:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchAttendances();
  }, []);

  const handleEditClick = (attendance) => {
    setSelectedAttendance(attendance);
    setIsModalOpen(true);
  };

  const handleUpdate = async (id, updatedData) => {
    try {
      const updatedRecord = await attendanceService.update(id, updatedData);
      
      // Update local state
      setAttendances(prev => 
        prev.map(item => item._id === id ? { ...item, ...updatedRecord } : item)
      );
    } catch (error) {
      console.error("Failed to update attendance:", error);
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric'
    });
  };

  const formatTime = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleTimeString('en-US', {
      hour: '2-digit', minute: '2-digit'
    });
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'Checked In':
        return <span className="px-2.5 py-1 text-xs font-medium bg-green-500/10 text-green-400 border border-green-500/20 rounded-full flex items-center gap-1"><CheckCircle className="w-3 h-3"/> {status}</span>;
      case 'Checked Out':
        return <span className="px-2.5 py-1 text-xs font-medium bg-slate-500/10 text-slate-400 border border-slate-500/20 rounded-full flex items-center gap-1"><XCircle className="w-3 h-3"/> {status}</span>;
      default:
        return <span className="px-2.5 py-1 text-xs font-medium bg-blue-500/10 text-blue-400 border border-blue-500/20 rounded-full">{status}</span>;
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6 flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-white">Attendances</h1>
          <p className="text-slate-400 text-sm mt-1">Manage and view employee attendances</p>
        </div>
        <button 
          onClick={fetchAttendances}
          className="px-4 py-2 bg-slate-800 text-white rounded-lg border border-slate-700 hover:bg-slate-700 transition-colors text-sm font-medium"
        >
          Refresh Data
        </button>
      </div>

      <div className="bg-slate-800 rounded-xl shadow-sm border border-slate-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="text-xs uppercase bg-slate-900/50 text-slate-400 border-b border-slate-700">
              <tr>
                <th className="px-6 py-4 font-semibold">User ID</th>
                <th className="px-6 py-4 font-semibold">Date</th>
                <th className="px-6 py-4 font-semibold">Check In</th>
                <th className="px-6 py-4 font-semibold">Check Out</th>
                <th className="px-6 py-4 font-semibold">Location</th>
                <th className="px-6 py-4 font-semibold">Status</th>
                <th className="px-6 py-4 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan="7" className="px-6 py-12 text-center text-slate-500">
                    <div className="flex flex-col items-center justify-center">
                      <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                      <p>Loading attendances...</p>
                    </div>
                  </td>
                </tr>
              ) : attendances.length === 0 ? (
                <tr>
                  <td colSpan="7" className="px-6 py-12 text-center text-slate-500">
                    No attendances found
                  </td>
                </tr>
              ) : (
                attendances.map((attendance) => (
                  <tr key={attendance._id} className="border-b border-slate-700/50 hover:bg-slate-700/30 transition-colors">
                    <td className="px-6 py-4 font-mono text-xs">{attendance.userId.slice(-6)}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4 text-slate-500" />
                        {formatDate(attendance.date)}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4 text-slate-500" />
                        {formatTime(attendance.checkInTime)}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4 text-slate-500" />
                        {formatTime(attendance.checkOutTime)}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-slate-400 text-xs">
                      <div className="flex items-center gap-2">
                        <MapPin className="w-4 h-4 text-slate-500" />
                        <span className="truncate max-w-[150px]" title={attendance.location}>
                          {attendance.location || 'N/A'}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      {getStatusBadge(attendance.status)}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button
                        onClick={() => handleEditClick(attendance)}
                        className="p-2 text-slate-400 hover:text-white hover:bg-slate-700 rounded-lg transition-colors inline-flex items-center gap-1"
                        title="Edit Attendance"
                      >
                        <Edit2 className="w-4 h-4" />
                        <span className="text-xs font-medium">Edit</span>
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      <UpdateAttendanceModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        attendance={selectedAttendance}
        onUpdate={handleUpdate}
      />
    </div>
  );
};

export default Attendances;
