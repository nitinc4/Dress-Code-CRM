import React, { useState, useEffect } from 'react';
import { X, Loader2 } from 'lucide-react';

const UpdateAttendanceModal = ({ isOpen, onClose, attendance, onUpdate }) => {
  const [status, setStatus] = useState('');
  const [checkOutTime, setCheckOutTime] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (attendance) {
      setStatus(attendance.status || '');
      setCheckOutTime(
        attendance.checkOutTime 
          ? new Date(attendance.checkOutTime).toISOString().slice(0, 16) 
          : ''
      );
    }
  }, [attendance]);

  if (!isOpen || !attendance) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    
    const updatedData = {
      status,
      checkOutTime: checkOutTime ? new Date(checkOutTime).toISOString() : null,
    };
    
    await onUpdate(attendance._id, updatedData);
    setIsLoading(false);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="bg-slate-800 rounded-xl shadow-2xl w-full max-w-md overflow-hidden">
        <div className="flex justify-between items-center p-6 border-b border-slate-700">
          <h3 className="text-xl font-semibold text-white">Update Attendance</h3>
          <button onClick={onClose} className="text-slate-400 hover:text-white transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>
        
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">User ID</label>
            <input 
              type="text" 
              disabled 
              value={attendance.userId} 
              className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-slate-400 cursor-not-allowed"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Status</label>
            <select
              value={status}
              onChange={(e) => setStatus(e.target.value)}
              className="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="Checked In">Checked In</option>
              <option value="Checked Out">Checked Out</option>
              <option value="Absent">Absent</option>
              <option value="Leave">Leave</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Check Out Time</label>
            <input
              type="datetime-local"
              value={checkOutTime}
              onChange={(e) => setCheckOutTime(e.target.value)}
              className="w-full bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          
          <div className="pt-4 flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 rounded-lg text-sm font-medium text-slate-300 hover:bg-slate-700 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:ring-2 focus:ring-blue-500 transition-colors disabled:opacity-50"
            >
              {isLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Save Changes'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default UpdateAttendanceModal;
