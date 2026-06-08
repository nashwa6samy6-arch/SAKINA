import { MapPin, Bed, Bath, Square } from "lucide-react";
import { PremiumBadge } from "./PremiumBadge";

export type Property = {
  id: number;
  title: string;
  address: string;
  price: number;
  beds: number;
  baths: number;
  sqft: number;
  image: string;
  isPremium: boolean;
  landlord: string;
};

export function PropertyCard({ property }: { property: Property }) {
  return (
    <div
      className={`bg-card rounded-xl overflow-hidden border transition-shadow hover:shadow-lg cursor-pointer ${
        property.isPremium
          ? "ring-2 shadow-md"
          : "border-border"
      }`}
      style={
        property.isPremium
          ? { ringColor: "var(--premium)", borderColor: "var(--premium)" }
          : {}
      }
    >
      <div className="relative">
        <img
          src={property.image}
          alt={property.title}
          className="w-full h-48 object-cover"
        />
        {property.isPremium && (
          <div className="absolute top-3 left-3">
            <PremiumBadge />
          </div>
        )}
        <div className="absolute bottom-3 right-3 bg-primary text-primary-foreground px-3 py-1 rounded-lg text-sm font-semibold" style={{ fontFamily: "DM Mono, monospace" }}>
          ${property.price.toLocaleString()}/mo
        </div>
      </div>
      <div className="p-4">
        <h3 className="font-semibold text-foreground mb-1 truncate" style={{ fontFamily: "Playfair Display, serif" }}>
          {property.title}
        </h3>
        <div className="flex items-center gap-1 text-muted-foreground text-sm mb-3">
          <MapPin size={13} />
          <span className="truncate">{property.address}</span>
        </div>
        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <span className="flex items-center gap-1"><Bed size={13} /> {property.beds} bd</span>
          <span className="flex items-center gap-1"><Bath size={13} /> {property.baths} ba</span>
          <span className="flex items-center gap-1"><Square size={13} /> {property.sqft.toLocaleString()} ft²</span>
        </div>
      </div>
    </div>
  );
}
