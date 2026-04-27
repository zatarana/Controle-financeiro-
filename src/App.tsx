import { Code2, Github, Layers, LineChart, Smartphone } from "lucide-react";

export default function App() {
  return (
    <div className="min-h-screen bg-neutral-950 text-neutral-50 flex items-center justify-center p-6 font-sans">
      <div className="max-w-5xl w-full grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
        <div className="flex flex-col space-y-8">
          <div className="space-y-3">
            <h1 className="text-5xl font-bold tracking-tight bg-gradient-to-r from-indigo-400 to-blue-500 bg-clip-text text-transparent">
              CtrlFinance
            </h1>
            <p className="text-xl text-neutral-400">
              Engenharia de APK Nativo Concluída.
            </p>
          </div>

          <div className="flex flex-col gap-5 border border-neutral-800/60 bg-neutral-900/40 p-6 rounded-2xl shadow-xl">
            <div className="flex items-start gap-4">
              <div className="p-2.5 bg-blue-500/10 text-blue-400 rounded-xl">
                <Layers className="w-6 h-6" />
              </div>
              <div>
                <h3 className="font-semibold text-neutral-200">
                  Dart & Flutter
                </h3>
                <p className="text-sm text-neutral-400 mt-1 leading-relaxed">
                  Estrutura construída no diretório <code>/flutter_app</code> com{" "}
                  <code>SharedPreferences</code> para sync local e{" "}
                  <code>Provider</code> para gerência de estado.
                </p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="p-2.5 bg-emerald-500/10 text-emerald-400 rounded-xl">
                <Code2 className="w-6 h-6" />
              </div>
              <div>
                <h3 className="font-semibold text-neutral-200">
                  Módulo de Dívidas
                </h3>
                <p className="text-sm text-neutral-400 mt-1 leading-relaxed">
                  Formulários exclusivos para inclusão rápida de dívidas e
                  empréstimos pendentes.
                </p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="p-2.5 bg-purple-500/10 text-purple-400 rounded-xl">
                <Github className="w-6 h-6" />
              </div>
              <div>
                <h3 className="font-semibold text-neutral-200">
                  Pipeline CI/CD (GitHub Actions)
                </h3>
                <p className="text-sm text-neutral-400 mt-1 leading-relaxed">
                  Workflow mapeado em <code>.github/workflows/build-apk.yml</code>. O APK
                  será gerado automaticamente acessando a aba Actions do seu repositório.
                </p>
              </div>
            </div>
          </div>

          <div>
            <div className="inline-flex items-center gap-2 px-5 py-3 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl font-medium transition-colors shadow-lg shadow-indigo-500/20">
              <Github className="w-5 h-5" />
              Exporte para o GitHub via AI Studio
            </div>
          </div>
        </div>

        {/* Device Mockup */}
        <div className="flex justify-center items-center">
          <div className="relative w-[320px] h-[650px] border-[10px] border-neutral-800 rounded-[3rem] overflow-hidden bg-[#121212] shadow-2xl flex flex-col ring-1 ring-neutral-700/50">
            {/* Notch */}
            <div className="absolute top-0 inset-x-0 h-6 bg-neutral-800 rounded-b-2xl mx-16 z-10 flex justify-center items-end pb-1">
              <div className="w-12 h-1.5 bg-black/40 rounded-full"></div>
            </div>

            {/* App Header */}
            <div className="pt-10 pb-4 px-6 bg-[#1e1e1e] flex justify-center items-center border-b border-white/5">
              <span className="font-bold text-white tracking-wide">
                CtrlFinance
              </span>
            </div>

            {/* App Body Mockup */}
            <div className="flex-1 overflow-y-auto p-4 flex flex-col gap-5">
              <div className="bg-gradient-to-br from-indigo-600 to-blue-600 rounded-2xl p-6 text-white shadow-xl">
                <p className="text-indigo-100 text-sm font-medium">Saldo Atual</p>
                <h2 className="text-3xl font-bold mt-1">R$ 14.850,00</h2>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="bg-[#1e1e1e] border border-red-500/30 rounded-2xl p-4">
                  <p className="text-neutral-400 text-xs flex items-center gap-1">
                    <span className="text-red-400">↓</span> Dívidas
                  </p>
                  <p className="text-red-400 font-bold text-lg mt-1">R$ 2.450</p>
                </div>
                <div className="bg-[#1e1e1e] border border-emerald-500/30 rounded-2xl p-4">
                  <p className="text-neutral-400 text-xs flex items-center gap-1">
                    <span className="text-emerald-400">↑</span> Empréstimos
                  </p>
                  <p className="text-emerald-400 font-bold text-lg mt-1">
                    R$ 1.800
                  </p>
                </div>
              </div>

              <div>
                <p className="text-white font-bold mb-3 px-1">Relatórios</p>
                <div className="bg-[#1e1e1e] rounded-2xl p-6 flex flex-col items-center">
                  <div className="aspect-square rounded-full border-[18px] border-neutral-800 border-t-red-500 border-r-emerald-500 border-l-emerald-500 border-b-red-500 rotate-12 mx-auto w-32 h-32 relative">
                    <div className="absolute inset-0 flex items-center justify-center flex-col">
                    </div>
                  </div>
                  <div className="mt-6 flex justify-between gap-6 text-xs font-medium text-neutral-300">
                    <span className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full bg-red-500"></div>{" "}
                      65% Despesas
                    </span>
                    <span className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full bg-emerald-500"></div>{" "}
                      35% Receitas
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* Bottom Nav */}
            <div className="h-20 bg-[#1e1e1e] border-t border-white/5 flex justify-around items-center text-neutral-500 pb-3">
              <div className="flex flex-col items-center gap-1 text-indigo-400">
                <Smartphone className="w-6 h-6" />
                <span className="text-[10px] font-medium">Início</span>
              </div>
              <div className="flex flex-col items-center gap-1 hover:text-white transition-colors">
                <Layers className="w-6 h-6" />
                <span className="text-[10px] font-medium">Dívidas</span>
              </div>
              <div className="flex flex-col items-center gap-1 hover:text-white transition-colors">
                <LineChart className="w-6 h-6" />
                <span className="text-[10px] font-medium">Relatórios</span>
              </div>
            </div>
            <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-32 h-1 bg-white/20 rounded-full"></div>
          </div>
        </div>
      </div>
    </div>
  );
}

