import { useState } from "react";
import { Star, Calendar, Clock, AlertTriangle, CheckCircle, Plus, Bed, Bath, Square, MapPin } from "lucide-react";
import { PremiumBadge } from "./PremiumBadge";
import { PremiumSubscriptionScreen } from "./PremiumSubscriptionScreen";
import type { Plan } from "./PremiumSubscriptionScreen";
import { format, addDays } from "date-fns";

type Listing = {
  id: number;
  title: string;
  address: string;
  beds: number;
  baths: number;
  sqft: number;
  image: string;
  premium: null | {
    status: "active" | "suspended";
    plan: string;
    startDate: Date;
    endDate: Date;
  };
};

const INITIAL_LISTINGS: Listing[] = [
  {
    id: 1,
    title: "The Meridian Penthouse",
    address: "820 Fifth Avenue, New York, NY",
    beds: 3, baths: 2, sqft: 1850,
    image: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400&h=280&fit=crop&auto=format",
    premium: {
      status: "active",
      plan: "Quarterly Plan",
      startDate: new Date(2026, 4, 1),
      endDate: new Date(2026, 6, 31),
    },
  },
  {
    id: 2,
    title: "Riverside Loft Residence",
    address: "340 West 28th St, New York, NY",
    beds: 2, baths: 2, sqft: 1200,
    image: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400&h=280&fit=crop&auto=format",
    premium: null,
  },
  {
    id: 3,
    title: "SoHo Artist Studio",
    address: "88 Greene St, New York, NY",
    beds: 1, baths: 1, sqft: 660,
    image: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400&h=280&fit=crop&auto=format",
    premium: {
      status: "suspended",
      plan: "Monthly Plan",
      startDate: new Date(2026, 3, 10),
      endDate: new Date(2026, 4, 10),
    },
  },
];

function StatusPill({ status }: { status: "active" | "suspended" }) {
  if (status === "active") {
    return (
      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-200">
        <CheckCircle size={10} /> Active
      </span>
    );
  }
  return (
    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-red-50 text-red-700 border border-red-200">
      <AlertTriangle size={10} /> Suspended
    </span>
  );
}

export function LandlordDashboard() {
  const [listings, setListings] = useState<Listing[]>(INITIAL_LISTINGS);
  const [modalListingId, setModalListingId] = useState<number | null>(2);

  const modalListing = listings.find((l) => l.id === modalListingId) ?? null;

  const handleSubscriptionSuccess = (plan: Plan) => {
    if (modalListingId === null) return;
    const now = new Date();
    setListings((prev) =>
      prev.map((l) =>
        l.id === modalListingId
          ? {
              ...l,
              premium: {
                status: "active",
                plan: plan.name + " Plan",
                startDate: now,
                endDate: addDays(now, plan.durationDays),
              },
            }
          : l
      )
    );
    setModalListingId(null);
  };

  const activePremium = listings.filter((l) => l.premium?.status === "active").length;
  const totalListings = listings.length;

  if (modalListing) {
    return (
      <PremiumSubscriptionScreen
        propertyTitle={modalListing.title}
        propertyImage={modalListing.image}
        propertyAddress={modalListing.address}
        onBack={() => setModalListingId(null)}
        onSuccess={handleSubscriptionSuccess}
      />
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-6 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-foreground mb-1" style={{ fontFamily: "Playfair Display, serif", fontSize: "2rem" }}>
          My Listings
        </h1>
        <p className="text-muted-foreground text-sm">
          {totalListings} properties · {activePremium} with active premium
        </p>
      </div>

      {/* Summary cards */}
      <div className="grid grid-cols-3 gap-4 mb-8">
        <div className="bg-card rounded-xl p-4 border border-border">
          <p className="text-xs text-muted-foreground mb-1 uppercase tracking-wide">Total Listings</p>
          <p className="text-2xl font-semibold text-foreground" style={{ fontFamily: "DM Mono, monospace" }}>{totalListings}</p>
        </div>
        <div className="bg-card rounded-xl p-4 border border-border" style={{ borderColor: "oklch(from var(--premium) l c h / 0.35)" }}>
          <p className="text-xs mb-1 uppercase tracking-wide" style={{ color: "var(--premium)" }}>Active Premium</p>
          <p className="text-2xl font-semibold" style={{ fontFamily: "DM Mono, monospace", color: "var(--premium)" }}>{activePremium}</p>
        </div>
        <div className="bg-card rounded-xl p-4 border border-border">
          <p className="text-xs text-muted-foreground mb-1 uppercase tracking-wide">Standard</p>
          <p className="text-2xl font-semibold text-foreground" style={{ fontFamily: "DM Mono, monospace" }}>{totalListings - activePremium}</p>
        </div>
      </div>

      {/* Listings */}
      <div className="flex flex-col gap-4">
        {listings.map((listing) => (
          <div
            key={listing.id}
            className={`bg-card rounded-xl border overflow-hidden flex flex-col sm:flex-row ${
              listing.premium?.status === "active" ? "border-2" : "border-border"
            }`}
            style={
              listing.premium?.status === "active"
                ? { borderColor: "var(--premium)" }
                : {}
            }
          >
            <div className="relative sm:w-48 h-40 sm:h-auto shrink-0">
              <img src={listing.image} alt={listing.title} className="w-full h-full object-cover" />
              {listing.premium?.status === "active" && (
                <div className="absolute top-2 left-2">
                  <PremiumBadge />
                </div>
              )}
            </div>
            <div className="p-5 flex-1 flex flex-col justify-between">
              <div>
                <div className="flex items-start justify-between gap-2 mb-1">
                  <h3 className="font-semibold text-foreground" style={{ fontFamily: "Playfair Display, serif" }}>
                    {listing.title}
                  </h3>
                  {listing.premium && <StatusPill status={listing.premium.status} />}
                </div>
                <div className="flex items-center gap-1 text-muted-foreground text-xs mb-3">
                  <MapPin size={11} /> {listing.address}
                </div>
                <div className="flex items-center gap-3 text-xs text-muted-foreground mb-4">
                  <span className="flex items-center gap-1"><Bed size={11} /> {listing.beds} bd</span>
                  <span className="flex items-center gap-1"><Bath size={11} /> {listing.baths} ba</span>
                  <span className="flex items-center gap-1"><Square size={11} /> {listing.sqft.toLocaleString()} ft²</span>
                </div>

                {/* Subscription details */}
                {listing.premium ? (
                  <div
                    className="rounded-lg p-3 text-xs flex flex-col gap-1.5"
                    style={{
                      background: listing.premium.status === "active"
                        ? "oklch(from var(--premium) l c h / 0.06)"
                        : "rgba(197,48,48,0.06)",
                    }}
                  >
                    <div className="flex items-center gap-2 font-medium" style={{ color: listing.premium.status === "active" ? "var(--premium)" : "#c53030" }}>
                      <Star size={12} fill="currentColor" />
                      {listing.premium.plan}
                    </div>
                    <div className="flex gap-4 text-muted-foreground">
                      <span className="flex items-center gap-1">
                        <Calendar size={11} />
                        Started {format(listing.premium.startDate, "MMM d, yyyy")}
                      </span>
                      <span className="flex items-center gap-1">
                        <Clock size={11} />
                        {listing.premium.status === "active" ? "Expires" : "Expired"} {format(listing.premium.endDate, "MMM d, yyyy")}
                      </span>
                    </div>
                    {listing.premium.status === "suspended" && (
                      <p className="text-red-600 flex items-center gap-1">
                        <AlertTriangle size={11} />
                        Premium suspended due to failed or reversed transaction.
                      </p>
                    )}
                  </div>
                ) : (
                  <div className="rounded-lg p-3 text-xs text-muted-foreground border border-dashed border-border">
                    No active premium subscription
                  </div>
                )}
              </div>

              <div className="mt-4 flex gap-2">
                {listing.premium?.status === "active" ? (
                  <button
                    className="text-xs px-3 py-1.5 rounded-lg border border-border text-muted-foreground hover:bg-secondary transition-colors"
                    onClick={() => alert("Renewal flow coming soon.")}
                  >
                    Renew early
                  </button>
                ) : (
                  <button
                    onClick={() => setModalListingId(listing.id)}
                    className="flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-lg font-semibold transition-opacity hover:opacity-90"
                    style={{ background: "var(--premium)", color: "var(--premium-foreground)" }}
                  >
                    <Plus size={12} />
                    {listing.premium?.status === "suspended" ? "Reactivate Premium" : "Upgrade to Premium"}
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
