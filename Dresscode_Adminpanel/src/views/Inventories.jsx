import React, { useState, useEffect } from 'react';
import { inventoryService } from '../services/api';
import { Package, Hash, Calendar, AlertTriangle, CheckCircle } from 'lucide-react';

const Inventories = () => {
  const [inventories, setInventories] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const fetchInventories = async () => {
    setIsLoading(true);
    try {
      const data = await inventoryService.getAll();
      setInventories(data);
    } catch (error) {
      console.error("Error fetching inventories:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchInventories();
  }, []);

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric'
    });
  };

  const getStockStatus = (quantity, threshold) => {
    if (quantity <= 0) {
      return <span className="px-2.5 py-1 text-xs font-medium bg-red-50 text-red-700 border border-red-200 rounded-full flex items-center gap-1 w-fit"><AlertTriangle className="w-3 h-3"/> Out of Stock</span>;
    } else if (quantity <= threshold) {
      return <span className="px-2.5 py-1 text-xs font-medium bg-yellow-50 text-yellow-700 border border-yellow-200 rounded-full flex items-center gap-1 w-fit"><AlertTriangle className="w-3 h-3"/> Low Stock</span>;
    } else {
      return <span className="px-2.5 py-1 text-xs font-medium bg-green-50 text-green-700 border border-green-200 rounded-full flex items-center gap-1 w-fit"><CheckCircle className="w-3 h-3"/> In Stock</span>;
    }
  };

  return (
    <div className="p-0 md:p-4">
      <div className="mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-black">Inventory Management</h1>
          <p className="text-gray-600 text-sm mt-1">Track fabric and material stock levels</p>
        </div>
        <button 
          onClick={fetchInventories}
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
                <th className="px-6 py-4 font-semibold">Item Details</th>
                <th className="px-6 py-4 font-semibold">Quantity</th>
                <th className="px-6 py-4 font-semibold">Status</th>
                <th className="px-6 py-4 font-semibold">Last Updated</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan="4" className="px-6 py-12 text-center text-gray-500">
                    <div className="flex flex-col items-center justify-center">
                      <div className="w-8 h-8 border-4 border-gold-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                      <p>Loading inventory...</p>
                    </div>
                  </td>
                </tr>
              ) : inventories.length === 0 ? (
                <tr>
                  <td colSpan="4" className="px-6 py-12 text-center text-gray-500">
                    No inventory items found.
                  </td>
                </tr>
              ) : (
                inventories.map((item) => (
                  <tr key={item._id} className="border-b border-gray-100 hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-teal-50 flex items-center justify-center text-teal-600 border border-teal-100">
                          <Package className="w-5 h-5" />
                        </div>
                        <div>
                          <div className="font-medium text-black">{item.itemName || 'Unnamed Item'}</div>
                          <div className="text-xs text-gray-500 capitalize mt-0.5">{item.category || 'Uncategorized'}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <Hash className="w-4 h-4 text-gray-400" />
                        <span className="font-bold text-black">{item.quantity}</span>
                        <span className="text-gray-500 text-xs">{item.unit}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      {getStockStatus(item.quantity, item.lowStockThreshold)}
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2 text-gray-600">
                        <Calendar className="w-4 h-4 text-gray-400" />
                        {formatDate(item.lastUpdated || item.createdAt)}
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

export default Inventories;
