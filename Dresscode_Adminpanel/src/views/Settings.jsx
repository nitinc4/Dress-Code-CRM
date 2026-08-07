import React from 'react';
import { Settings as SettingsIcon, Bell, Shield, Key } from 'lucide-react';

const Settings = () => {
  return (
    <div className="p-4 md:p-8 max-w-4xl mx-auto">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-black flex items-center gap-2">
          <SettingsIcon className="w-6 h-6" />
          Settings
        </h1>
        <p className="text-gray-600 mt-1">Manage your admin preferences and application settings.</p>
      </div>

      <div className="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden mb-6">
        <div className="p-6 border-b border-gray-100">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2 bg-gold-500/10 text-gold-600 rounded-lg">
              <Shield className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-black">Security</h2>
              <p className="text-sm text-gray-500">Update your password and secure your account.</p>
            </div>
          </div>
          <button className="px-4 py-2 bg-black text-white rounded-lg text-sm font-medium hover:bg-gray-900 transition-colors">
            Change Password
          </button>
        </div>

        <div className="p-6 border-b border-gray-100">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2 bg-gold-500/10 text-gold-600 rounded-lg">
              <Bell className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-black">Notifications</h2>
              <p className="text-sm text-gray-500">Choose what you want to be notified about.</p>
            </div>
          </div>
          <div className="space-y-3">
            <label className="flex items-center gap-3 text-sm text-gray-700 cursor-pointer">
              <input type="checkbox" className="rounded text-gold-500 focus:ring-gold-500 w-4 h-4 cursor-pointer" defaultChecked />
              Email alerts for new orders
            </label>
            <label className="flex items-center gap-3 text-sm text-gray-700 cursor-pointer">
              <input type="checkbox" className="rounded text-gold-500 focus:ring-gold-500 w-4 h-4 cursor-pointer" defaultChecked />
              Email alerts for low inventory
            </label>
            <label className="flex items-center gap-3 text-sm text-gray-700 cursor-pointer">
              <input type="checkbox" className="rounded text-gold-500 focus:ring-gold-500 w-4 h-4 cursor-pointer" />
              Daily attendance summary
            </label>
          </div>
        </div>

        <div className="p-6">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2 bg-gold-500/10 text-gold-600 rounded-lg">
              <Key className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-black">API Access</h2>
              <p className="text-sm text-gray-500">Manage API keys for external integrations.</p>
            </div>
          </div>
          <button className="px-4 py-2 border border-gray-300 text-black rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors">
            Generate New Key
          </button>
        </div>
      </div>
      
      <div className="flex justify-end gap-3">
        <button className="px-6 py-2 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200 transition-colors">
          Cancel
        </button>
        <button className="px-6 py-2 bg-gold-500 text-black rounded-lg text-sm font-medium hover:bg-gold-600 transition-colors shadow-sm">
          Save Changes
        </button>
      </div>
    </div>
  );
};

export default Settings;
