import { useState } from "react";
import { Home, LayoutDashboard, Star } from "lucide-react";
import { PropertySearch } from "./components/PropertySearch";
import { LandlordDashboard } from "./components/LandlordDashboard";

{
  /* MARKER-MAKE-KIT-INVOKED */
}

type Tab = "search" | "dashboard";

export default function App() {
  const [activeTab, setActiveTab] = useState<Tab>("dashboard");

  return (
    <div
      className="min-h-screen bg-background"
      style={{ fontFamily: "Inter, sans-serif" }}
    >
      {/* Navbar */}
      <header className="bg-primary text-primary-foreground sticky top-0 z-40 shadow-sm">
        <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Home size={20} />
            <span
              style={{
                fontFamily: "Playfair Display, serif",
                fontSize: "1.1rem",
                letterSpacing: "-0.01em",
              }}
            >
              NestFind
            </span>
          </div>

          <nav className="flex items-center gap-1">
            <button
              onClick={() => setActiveTab("search")}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm transition-colors ${
                activeTab === "search"
                  ? "bg-white/15 font-medium"
                  : "opacity-70 hover:opacity-100 hover:bg-white/10"
              }`}
            >
              <Home size={14} />
              Browse
            </button>
            <button
              onClick={() => setActiveTab("dashboard")}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm transition-colors ${
                activeTab === "dashboard"
                  ? "bg-white/15 font-medium"
                  : "opacity-70 hover:opacity-100 hover:bg-white/10"
              }`}
            >
              <LayoutDashboard size={14} />
              My Listings
            </button>
          </nav>

          <div className="flex items-center gap-2 text-xs opacity-80">
            <Star
              size={12}
              fill="currentColor"
              style={{ color: "var(--premium)" }}
            />
            <span style={{ color: "var(--premium)" }}>
              Premium
            </span>
          </div>
        </div>
      </header>

      {/* Tab indicator */}
      <div className="border-b border-border bg-card">
        <div className="max-w-6xl mx-auto px-6">
          <div className="flex gap-0">
            {(["search", "dashboard"] as Tab[]).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`py-3 text-sm border-b-2 transition-colors mr-6 ${
                  activeTab === tab
                    ? "font-semibold text-foreground"
                    : "text-muted-foreground hover:text-foreground border-transparent"
                }`}
                style={
                  activeTab === tab
                    ? { borderColor: "var(--premium)" }
                    : {}
                }
              >
                {tab === "search"
                  ? "Property Search"
                  : "Landlord Dashboard"}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Content */}
      <main>
        {activeTab === "search" && <PropertySearch />}
        {activeTab === "dashboard" && <LandlordDashboard />}
      </main>
    </div>
  );
}