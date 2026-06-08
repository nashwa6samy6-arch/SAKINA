import { useState } from "react";
import { Search, SlidersHorizontal, Star } from "lucide-react";
import { PropertyCard, Property } from "./PropertyCard";

const ALL_PROPERTIES: Property[] = [
  {
    id: 1,
    title: "The Meridian Penthouse",
    address: "820 Fifth Avenue, New York, NY 10065",
    price: 8500,
    beds: 3,
    baths: 2,
    sqft: 1850,
    image: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&h=400&fit=crop&auto=format",
    isPremium: true,
    landlord: "Hargrove Properties",
  },
  {
    id: 2,
    title: "Riverside Loft Residence",
    address: "340 West 28th St, New York, NY 10001",
    price: 5200,
    beds: 2,
    baths: 2,
    sqft: 1200,
    image: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600&h=400&fit=crop&auto=format",
    isPremium: true,
    landlord: "Urban Nest LLC",
  },
  {
    id: 3,
    title: "Chelsea Garden Apartment",
    address: "112 West 18th St, New York, NY 10011",
    price: 3800,
    beds: 1,
    baths: 1,
    sqft: 720,
    image: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&h=400&fit=crop&auto=format",
    isPremium: false,
    landlord: "J. Morales",
  },
  {
    id: 4,
    title: "Brooklyn Heights Classic",
    address: "55 Pierrepont St, Brooklyn, NY 11201",
    price: 3200,
    beds: 2,
    baths: 1,
    sqft: 950,
    image: "https://images.unsplash.com/photo-1484154218962-a197022b5858?w=600&h=400&fit=crop&auto=format",
    isPremium: false,
    landlord: "T. Chen",
  },
  {
    id: 5,
    title: "Upper West Studio",
    address: "201 West 79th St, New York, NY 10024",
    price: 2400,
    beds: 0,
    baths: 1,
    sqft: 480,
    image: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop&auto=format",
    isPremium: false,
    landlord: "S. Patel",
  },
  {
    id: 6,
    title: "Tribeca Grand Floor-Through",
    address: "72 Franklin St, New York, NY 10013",
    price: 6800,
    beds: 3,
    baths: 3,
    sqft: 2100,
    image: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&h=400&fit=crop&auto=format",
    isPremium: false,
    landlord: "Franklin Realty Group",
  },
];

export function PropertySearch() {
  const [query, setQuery] = useState("");
  const [showPremiumOnly, setShowPremiumOnly] = useState(false);

  const filtered = ALL_PROPERTIES.filter((p) => {
    const matchesQuery =
      query === "" ||
      p.title.toLowerCase().includes(query.toLowerCase()) ||
      p.address.toLowerCase().includes(query.toLowerCase());
    const matchesPremium = !showPremiumOnly || p.isPremium;
    return matchesQuery && matchesPremium;
  });

  // Premium listings always appear first
  const sorted = [...filtered].sort((a, b) => {
    if (a.isPremium && !b.isPremium) return -1;
    if (!a.isPremium && b.isPremium) return 1;
    return 0;
  });

  const premiumCount = ALL_PROPERTIES.filter((p) => p.isPremium).length;

  return (
    <div className="max-w-6xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-foreground mb-1" style={{ fontFamily: "Playfair Display, serif", fontSize: "2rem" }}>
          Find Your Next Home
        </h1>
        <p className="text-muted-foreground text-sm">
          {ALL_PROPERTIES.length} listings available — {premiumCount} featured premium properties
        </p>
      </div>

      {/* Search bar */}
      <div className="flex gap-3 mb-6">
        <div className="flex-1 relative">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search by name or address…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="w-full pl-9 pr-4 py-2.5 bg-card border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
          />
        </div>
        <button
          onClick={() => setShowPremiumOnly((v) => !v)}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-lg text-sm border transition-colors font-medium ${
            showPremiumOnly
              ? "text-white border-transparent"
              : "bg-card border-border text-foreground hover:bg-secondary"
          }`}
          style={showPremiumOnly ? { background: "var(--premium)", borderColor: "var(--premium)" } : {}}
        >
          <Star size={14} fill={showPremiumOnly ? "currentColor" : "none"} />
          Premium only
        </button>
        <button className="flex items-center gap-2 px-4 py-2.5 rounded-lg text-sm bg-card border border-border text-foreground hover:bg-secondary transition-colors">
          <SlidersHorizontal size={14} />
          Filters
        </button>
      </div>

      {/* Premium callout banner */}
      <div
        className="rounded-xl p-4 mb-6 flex items-center gap-3 text-sm"
        style={{ background: "oklch(from var(--premium) l c h / 0.08)", border: "1px solid oklch(from var(--premium) l c h / 0.25)" }}
      >
        <Star size={16} style={{ color: "var(--premium)" }} fill="currentColor" />
        <span className="text-foreground">
          <span className="font-semibold" style={{ color: "var(--premium)" }}>Premium listings</span> appear at the top of search results with a verified badge — upgraded visibility for serious landlords.
        </span>
      </div>

      {/* Results */}
      {sorted.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground text-sm">No listings match your search.</div>
      ) : (
        <>
          <p className="text-xs text-muted-foreground mb-4 uppercase tracking-wide">
            {sorted.length} result{sorted.length !== 1 ? "s" : ""}
            {showPremiumOnly ? " · Premium only" : ""}
          </p>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {sorted.map((p) => (
              <PropertyCard key={p.id} property={p} />
            ))}
          </div>
        </>
      )}
    </div>
  );
}
