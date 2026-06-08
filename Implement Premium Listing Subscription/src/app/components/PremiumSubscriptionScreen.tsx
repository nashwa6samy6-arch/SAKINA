import { useState } from "react";
import { Star, CreditCard, CheckCircle, AlertCircle, Lock, ArrowLeft, Building2, MapPin, Sparkles } from "lucide-react";

export type Plan = {
  id: string;
  name: string;
  price: number;
  duration: string;
  durationDays: number;
  perks: string[];
  popular?: boolean;
};

const PLANS: Plan[] = [
  {
    id: "monthly",
    name: "Monthly",
    price: 49,
    duration: "1 month",
    durationDays: 30,
    perks: ["Top placement in search", "Premium badge on listing", "Priority support"],
  },
  {
    id: "quarterly",
    name: "Quarterly",
    price: 129,
    duration: "3 months",
    durationDays: 90,
    perks: ["Top placement in search", "Premium badge on listing", "Priority support", "Save 12%"],
    popular: true,
  },
  {
    id: "annual",
    name: "Annual",
    price: 399,
    duration: "12 months",
    durationDays: 365,
    perks: ["Top placement in search", "Premium badge on listing", "Priority support", "Save 32%", "Dedicated account manager"],
  },
];

type Step = "select" | "payment" | "processing" | "success" | "failed";

type Props = {
  propertyTitle: string;
  propertyImage?: string;
  propertyAddress?: string;
  onBack: () => void;
  onSuccess: (plan: Plan) => void;
};

export function PremiumSubscriptionScreen({ propertyTitle, propertyImage, propertyAddress, onBack, onSuccess }: Props) {
  const [step, setStep] = useState<Step>("select");
  const [selectedPlan, setSelectedPlan] = useState<Plan>(PLANS[1]);
  const [cardNumber, setCardNumber] = useState("");
  const [cardName, setCardName] = useState("");
  const [expiry, setExpiry] = useState("");
  const [cvv, setCvv] = useState("");
  const [simulateFail, setSimulateFail] = useState(false);

  const formatCard = (v: string) =>
    v.replace(/\D/g, "").slice(0, 16).replace(/(.{4})/g, "$1 ").trim();
  const formatExpiry = (v: string) => {
    const d = v.replace(/\D/g, "").slice(0, 4);
    return d.length >= 3 ? `${d.slice(0, 2)}/${d.slice(2)}` : d;
  };

  const handlePay = () => {
    if (!cardNumber || !cardName || !expiry || !cvv) return;
    setStep("processing");
    setTimeout(() => {
      if (simulateFail) {
        setStep("failed");
      } else {
        setStep("success");
      }
    }, 2500);
  };

  const handleComplete = () => {
    onSuccess(selectedPlan);
  };

  return (
    <div className="max-w-6xl mx-auto px-6 py-8 animate-in fade-in duration-300">
      <button 
        onClick={onBack}
        className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors mb-6"
      >
        <ArrowLeft size={16} />
        Back to Dashboard
      </button>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        
        {/* Left Column: Form & Flow */}
        <div className="lg:col-span-7 flex flex-col">
          <div className="mb-8">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-accent/10 text-accent font-medium text-xs uppercase tracking-wider mb-4 border border-accent/20">
              <Sparkles size={14} />
              Premium Upgrade
            </div>
            <h1 className="text-3xl md:text-4xl text-foreground font-semibold mb-3" style={{ fontFamily: "Playfair Display, serif" }}>
              {step === "success" ? "You're all set!" : step === "failed" ? "Payment Failed" : "Elevate Your Listing"}
            </h1>
            <p className="text-muted-foreground text-lg max-w-lg">
              {step === "select" && "Choose a premium plan to prioritize your property in search results and attract high-quality tenants faster."}
              {step === "payment" && "Enter your payment details to securely activate your premium subscription."}
              {step === "processing" && "We are securely processing your payment..."}
              {step === "success" && "Your property is now featured at the top of search results with a premium badge."}
              {step === "failed" && "We couldn't process your payment. Please check your card details and try again."}
            </p>
          </div>

          <div className="bg-card border border-border rounded-2xl p-6 md:p-8 shadow-sm relative overflow-hidden">
            {/* Step: Select */}
            {step === "select" && (
              <div className="space-y-4">
                {PLANS.map((plan) => (
                  <button
                    key={plan.id}
                    onClick={() => setSelectedPlan(plan)}
                    className={`relative w-full text-left rounded-xl border p-5 transition-all flex flex-col md:flex-row md:items-center gap-4 ${
                      selectedPlan.id === plan.id
                        ? "border-accent bg-accent/5 ring-1 ring-accent shadow-sm"
                        : "border-border hover:border-muted-foreground/30 bg-card"
                    }`}
                  >
                    {plan.popular && (
                      <span className="absolute -top-3 right-6 text-[10px] uppercase tracking-wider px-3 py-1 rounded-full font-bold bg-accent text-accent-foreground shadow-sm">
                        Most Popular
                      </span>
                    )}
                    
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <div className={`w-5 h-5 rounded-full border flex items-center justify-center ${selectedPlan.id === plan.id ? 'border-accent' : 'border-muted-foreground'}`}>
                          {selectedPlan.id === plan.id && <div className="w-2.5 h-2.5 rounded-full bg-accent" />}
                        </div>
                        <span className="text-lg font-semibold text-foreground">{plan.name}</span>
                      </div>
                      <div className="ml-7 mt-2 grid grid-cols-1 sm:grid-cols-2 gap-y-2 gap-x-4">
                        {plan.perks.map((perk, i) => (
                          <span key={i} className="text-sm text-muted-foreground flex items-center gap-2">
                            <CheckCircle size={14} className="text-accent shrink-0" />
                            {perk}
                          </span>
                        ))}
                      </div>
                    </div>

                    <div className="md:text-right ml-7 md:ml-0">
                      <div className="flex items-baseline md:justify-end gap-1">
                        <span className="text-2xl font-bold text-foreground">${plan.price}</span>
                      </div>
                      <div className="text-sm text-muted-foreground">/ {plan.duration}</div>
                    </div>
                  </button>
                ))}

                <div className="pt-6">
                  <button
                    onClick={() => setStep("payment")}
                    className="w-full py-4 rounded-xl text-base font-semibold transition-all hover:opacity-90 shadow-md flex items-center justify-center gap-2"
                    style={{ background: "var(--primary)", color: "var(--primary-foreground)" }}
                  >
                    Continue to Payment
                  </button>
                </div>
              </div>
            )}

            {/* Step: Payment */}
            {step === "payment" && (
              <div className="animate-in fade-in slide-in-from-right-4 duration-300">
                <div className="flex items-center justify-between p-4 rounded-xl mb-6 border border-accent/20 bg-accent/5">
                  <div className="flex items-center gap-3">
                    <Star size={20} className="text-accent" fill="currentColor" />
                    <div>
                      <p className="text-sm font-medium text-foreground">{selectedPlan.name} Plan</p>
                      <p className="text-xs text-muted-foreground">Billed now</p>
                    </div>
                  </div>
                  <span className="text-xl font-bold text-foreground font-mono">${selectedPlan.price}</span>
                </div>

                <div className="space-y-5 mb-8">
                  <div>
                    <label className="block text-sm font-medium text-foreground mb-1.5">Cardholder Name</label>
                    <input
                      className="w-full px-4 py-3 rounded-xl border border-border bg-input-background text-base focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors"
                      placeholder="Jane Smith"
                      value={cardName}
                      onChange={(e) => setCardName(e.target.value)}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-foreground mb-1.5">Card Number</label>
                    <div className="relative">
                      <CreditCard size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground" />
                      <input
                        className="w-full pl-11 pr-4 py-3 rounded-xl border border-border bg-input-background text-base focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-mono"
                        placeholder="4242 4242 4242 4242"
                        value={cardNumber}
                        onChange={(e) => setCardNumber(formatCard(e.target.value))}
                      />
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-foreground mb-1.5">Expiry Date</label>
                      <input
                        className="w-full px-4 py-3 rounded-xl border border-border bg-input-background text-base focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-mono"
                        placeholder="MM/YY"
                        value={expiry}
                        onChange={(e) => setExpiry(formatExpiry(e.target.value))}
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-foreground mb-1.5">CVV</label>
                      <input
                        className="w-full px-4 py-3 rounded-xl border border-border bg-input-background text-base focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-mono"
                        placeholder="•••"
                        type="password"
                        maxLength={4}
                        value={cvv}
                        onChange={(e) => setCvv(e.target.value.replace(/\D/g, "").slice(0, 4))}
                      />
                    </div>
                  </div>
                </div>

                <div className="flex flex-col gap-4">
                  <label className="flex items-center gap-2 text-sm text-muted-foreground cursor-pointer select-none">
                    <input 
                      type="checkbox" 
                      checked={simulateFail} 
                      onChange={(e) => setSimulateFail(e.target.checked)} 
                      className="w-4 h-4 rounded border-border text-accent focus:ring-accent" 
                    />
                    Simulate payment failure (demo)
                  </label>
                  
                  <div className="flex gap-3">
                    <button
                      onClick={() => setStep("select")}
                      className="px-6 py-4 rounded-xl text-base font-semibold border border-border hover:bg-secondary transition-colors"
                    >
                      Back
                    </button>
                    <button
                      onClick={handlePay}
                      disabled={!cardNumber || !cardName || !expiry || !cvv}
                      className="flex-1 py-4 rounded-xl text-base font-semibold transition-all hover:opacity-90 shadow-md disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 bg-primary text-primary-foreground"
                    >
                      <Lock size={18} />
                      Pay ${selectedPlan.price}
                    </button>
                  </div>
                </div>
              </div>
            )}

            {/* Step: Processing */}
            {step === "processing" && (
              <div className="py-20 flex flex-col items-center justify-center gap-6 animate-in fade-in duration-300">
                <div className="relative">
                  <div className="w-16 h-16 rounded-full border-4 border-muted border-t-accent animate-spin" />
                  <Lock size={20} className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-muted-foreground" />
                </div>
                <div className="text-center">
                  <h3 className="text-lg font-semibold text-foreground mb-2">Processing Payment</h3>
                  <p className="text-sm text-muted-foreground">Please do not close this window...</p>
                </div>
              </div>
            )}

            {/* Step: Success */}
            {step === "success" && (
              <div className="py-12 flex flex-col items-center gap-6 text-center animate-in zoom-in-95 duration-500">
                <div className="w-24 h-24 rounded-full flex items-center justify-center bg-accent/10 border-8 border-accent/5">
                  <CheckCircle size={48} className="text-accent" />
                </div>
                <div>
                  <h3 className="text-2xl font-semibold text-foreground mb-3" style={{ fontFamily: "Playfair Display, serif" }}>Payment Successful!</h3>
                  <p className="text-muted-foreground max-w-sm mx-auto">
                    Your transaction is complete. <span className="font-medium text-foreground">{propertyTitle}</span> has been upgraded to Premium for the next {selectedPlan.duration}.
                  </p>
                </div>
                <button
                  onClick={handleComplete}
                  className="mt-4 px-8 py-4 rounded-xl text-base font-semibold shadow-md hover:opacity-90 transition-opacity bg-primary text-primary-foreground"
                >
                  Return to Dashboard
                </button>
              </div>
            )}

            {/* Step: Failed */}
            {step === "failed" && (
              <div className="py-12 flex flex-col items-center gap-6 text-center animate-in zoom-in-95 duration-500">
                <div className="w-24 h-24 rounded-full flex items-center justify-center bg-destructive/10 border-8 border-destructive/5">
                  <AlertCircle size={48} className="text-destructive" />
                </div>
                <div>
                  <h3 className="text-2xl font-semibold text-foreground mb-3" style={{ fontFamily: "Playfair Display, serif" }}>Payment Declined</h3>
                  <p className="text-muted-foreground max-w-sm mx-auto">
                    Your bank declined the transaction. No charges were made. Please try a different payment method.
                  </p>
                </div>
                <div className="flex gap-4 mt-4">
                  <button
                    onClick={onBack}
                    className="px-6 py-4 rounded-xl text-base font-semibold border border-border hover:bg-secondary transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={() => setStep("payment")}
                    className="px-8 py-4 rounded-xl text-base font-semibold shadow-md hover:opacity-90 transition-opacity bg-primary text-primary-foreground"
                  >
                    Try Again
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Right Column: Listing Preview */}
        <div className="lg:col-span-5">
          <div className="sticky top-24">
            <h3 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground mb-4">Target Property</h3>
            
            <div className="bg-card rounded-2xl border border-border overflow-hidden shadow-sm">
              <div className="h-48 w-full relative bg-muted">
                {propertyImage ? (
                  <img src={propertyImage} alt={propertyTitle} className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-muted-foreground">
                    <Building2 size={48} opacity={0.2} />
                  </div>
                )}
                
                {/* Preview Badge overlay */}
                <div className="absolute top-4 left-4 flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-white/95 backdrop-blur shadow-sm border border-black/5 animate-pulse">
                  <Star size={14} className="text-accent" fill="currentColor" />
                  <span className="text-xs font-bold text-accent tracking-wide uppercase">Premium</span>
                </div>
              </div>
              
              <div className="p-6">
                <h4 className="text-xl font-semibold text-foreground mb-2" style={{ fontFamily: "Playfair Display, serif" }}>
                  {propertyTitle}
                </h4>
                {propertyAddress && (
                  <p className="text-sm text-muted-foreground flex items-start gap-1.5 mb-6">
                    <MapPin size={16} className="shrink-0 mt-0.5" />
                    {propertyAddress}
                  </p>
                )}
                
                <div className="bg-secondary/50 rounded-xl p-4 border border-border/50">
                  <p className="text-xs font-medium text-foreground uppercase tracking-wider mb-3">Subscription Preview</p>
                  <ul className="space-y-3">
                    <li className="flex items-start gap-2 text-sm text-muted-foreground">
                      <CheckCircle size={16} className="text-accent shrink-0 mt-0.5" />
                      <span>Property pinned to top 3 slots in matching neighborhood searches</span>
                    </li>
                    <li className="flex items-start gap-2 text-sm text-muted-foreground">
                      <CheckCircle size={16} className="text-accent shrink-0 mt-0.5" />
                      <span>Distinctive gold styling to increase click-through rate by 45%</span>
                    </li>
                    <li className="flex items-start gap-2 text-sm text-muted-foreground">
                      <CheckCircle size={16} className="text-accent shrink-0 mt-0.5" />
                      <span>Direct messaging enabled with verified premium tenants</span>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  );
}
