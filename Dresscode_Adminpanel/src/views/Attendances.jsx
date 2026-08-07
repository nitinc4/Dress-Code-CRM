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
        return <span className="px-2.5 py-1 text-xs font-medium bg-neutral-500/10 text-black border border-neutral-500/20 rounded-full flex items-center gap-1"><XCircle className="w-3 h-3"/> {status}</span>;
      default:
        return <span className="px-2.5 py-1 text-xs font-medium bg-gold-500/10 text-gold-400 border border-gold-500/20 rounded-full">{status}</span>;
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6 flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-black">Attendances</h1>
          <p className="text-black text-sm mt-1">Manage and view employee attendances</p>
        </div>
        <button 
          onClick={fetchAttendances}
          className="px-4 py-2 bg-white text-black rounded-lg border border-gray-200 hover:bg-gray-100 transition-colors text-sm font-medium"
        >
          Refresh Data
        </button>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-black">
            <thead className="text-xs uppercase bg-gray-50/50 text-black border-b border-gray-200">
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
                  <td colSpan="7" className="px-6 py-12 text-center text-black">
                    <div className="flex flex-col items-center justify-center">
                      <div className="w-8 h-8 border-4 border-gold-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                      <p>Loading attendances...</p>
                    </div>
                  </td>
                </tr>
              ) : attendances.length === 0 ? (
                <tr>
                  <td colSpan="7" className="px-6 py-12 text-center text-black">
                    No attendances found
                  </td>
                </tr>
              ) : (
                attendances.map((attendance) => (
                  <tr key={attendance._id} className="border-b border-gray-200/50 hover:bg-gray-100/30 transition-colors">
                    <td className="px-6 py-4 font-mono text-xs">{attendance.userId.slice(-6)}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4 text-black" />
                        {formatDate(attendance.date)}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4 text-black" />
                        {formatTime(attendance.checkInTime)}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4 text-black" />
                        {formatTime(attendance.checkOutTime)}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-black text-xs">
                      <div className="flex items-center gap-2">
                        <MapPin className="w-4 h-4 text-black" />
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
                        className="p-2 text-black hover:text-black hover:bg-gray-100 rounded-lg transition-colors inline-flex items-center gap-1"
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
