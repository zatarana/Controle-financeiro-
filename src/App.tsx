import { Code2, Github, Layers, LineChart, Smartphone } from "lucide-react";

export default function App() {
  return (
    <div className="min-h-screen bg-gray-50 text-gray-900 flex items-center justify-center p-6 font-sans">
      <div className="max-w-5xl w-full grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
        <div className="flex flex-col space-y-8">
          <div className="space-y-3">
            <h1 className="text-5xl font-bold tracking-tight text-gray-900">
              CtrlFinance
            </h1>
            <p className="text-xl text-gray-500">
              Engenharia de APK Nativo Concluída.
            </p>
          </div>

          <div className="flex flex-col gap-5 bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
            <div className="flex items-start gap-4">
              <div className="p-2.5 bg-gray-50 border border-gray-100 text-gray-800 rounded-lg shadow-sm">
                <Layers className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-gray-800">
                  Dart & Flutter
                </h3>
                <p className="text-xs text-gray-500 mt-1 leading-relaxed">
                  Estrutura construída no diretório <code className="bg-gray-50 px-1 py-0.5 rounded text-[10px] font-mono border border-gray-200">/flutter_app</code> com{" "}
                  <code className="bg-gray-50 px-1 py-0.5 rounded text-[10px] font-mono border border-gray-200">SharedPreferences</code> para sync local e{" "}
                  <code className="bg-gray-50 px-1 py-0.5 rounded text-[10px] font-mono border border-gray-200">Provider</code> para gerência de estado.
                </p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="p-2.5 bg-gray-50 border border-gray-100 text-gray-800 rounded-lg shadow-sm">
                <Code2 className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-gray-800">
                  Módulo de Dívidas
                </h3>
                <p className="text-xs text-gray-500 mt-1 leading-relaxed">
                  Formulários exclusivos para inclusão rápida de dívidas e
                  empréstimos pendentes.
                </p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="p-2.5 bg-gray-50 border border-gray-100 text-gray-800 rounded-lg shadow-sm">
                <Github className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-gray-800">
                  Pipeline CI/CD (GitHub Actions)
                </h3>
                <p className="text-xs text-gray-500 mt-1 leading-relaxed">
                  Workflow mapeado em <code className="bg-gray-50 px-1 py-0.5 rounded text-[10px] font-mono border border-gray-200">.github/workflows/build-apk.yml</code>. O APK
                  será gerado automaticamente acessando a aba Actions do seu repositório.
                </p>
              </div>
            </div>
          </div>

          <div>
            <div className="inline-flex items-center gap-2 px-6 py-3 bg-black text-white hover:bg-gray-800 rounded-full font-medium transition-colors shadow-sm text-sm cursor-pointer">
              <Github className="w-4 h-4" />
              Exporte para o GitHub via AI Studio
            </div>
          </div>
        </div>

        {/* Device Mockup */}
        <div className="flex justify-center items-center">
          <div className="relative w-[320px] h-[650px] border-[10px] border-gray-900 rounded-[3rem] overflow-hidden bg-gray-50 flex flex-col shadow-2xl ring-1 ring-gray-200/50">
            {/* Notch */}
            <div className="absolute top-0 inset-x-0 h-6 bg-gray-900 rounded-b-2xl mx-16 z-10 flex justify-center items-end pb-1">
              <div className="w-12 h-1.5 bg-gray-800 rounded-full"></div>
            </div>

            {/* App Header */}
            <div className="pt-10 pb-4 px-6 bg-white flex justify-center items-center border-b border-gray-200">
              <span className="font-bold text-gray-900 tracking-tight text-lg">
                CtrlFinance
              </span>
            </div>

            {/* App Body Mockup */}
            <div className="flex-1 overflow-y-auto p-5 flex flex-col gap-6">
              <div className="bg-black p-5 rounded-2xl text-white shadow-lg relative overflow-hidden">
                <div className="relative z-10">
                  <p className="text-xs font-medium opacity-70">Saldo Atual</p>
                  <h2 className="text-2xl font-bold mt-1">R$ 14.850,00</h2>
                  <button className="mt-4 w-full bg-white text-black text-[10px] py-2 rounded font-bold uppercase tracking-widest">
                    Ver Auditoria
                  </button>
                </div>
                <div className="absolute -right-4 -bottom-4 w-24 h-24 bg-white opacity-10 rounded-full"></div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="bg-white border border-gray-100 border-l-4 border-l-red-500 rounded-2xl p-4 shadow-sm">
                  <p className="text-xs font-bold text-gray-800 flex items-center gap-1">
                    <span className="text-red-500">↓</span> Dívidas
                  </p>
                  <p className="text-gray-900 font-bold text-lg mt-1">R$ 2.450</p>
                </div>
                <div className="bg-white border border-gray-100 border-l-4 border-l-blue-500 rounded-2xl p-4 shadow-sm">
                  <p className="text-xs font-bold text-gray-800 flex items-center gap-1">
                    <span className="text-blue-500">↑</span> Empréstimos
                  </p>
                  <p className="text-gray-900 font-bold text-lg mt-1">
                    R$ 1.800
                  </p>
                </div>
              </div>

              <div>
                <h3 className="text-xs font-bold text-gray-800 uppercase tracking-wider mb-4 px-1">Relatórios</h3>
                <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm flex flex-col items-center">
                  <div className="aspect-square rounded-full border-[18px] border-gray-50 border-t-black border-r-gray-200 border-l-gray-200 border-b-black rotate-12 mx-auto w-32 h-32 relative">
                  </div>
                  <div className="mt-6 flex justify-between gap-6 font-bold uppercase text-[10px] text-gray-500">
                    <span className="flex items-center gap-2">
                      <div className="w-2.5 h-2.5 rounded-sm bg-gray-200"></div>{" "}
                      65% Despesas
                    </span>
                    <span className="flex items-center gap-2">
                      <div className="w-2.5 h-2.5 rounded-sm bg-black"></div>{" "}
                      35% Receitas
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* Bottom Nav */}
            <div className="h-20 bg-white border-t border-gray-200 flex justify-around items-center text-gray-400 pb-3 font-medium">
              <div className="flex flex-col items-center gap-1 text-black cursor-pointer px-3 py-1">
                <Smartphone className="w-6 h-6" />
                <span className="text-[10px]">Início</span>
              </div>
              <div className="flex flex-col items-center gap-1 hover:bg-gray-50 hover:text-gray-900 rounded-xl px-3 py-1 transition-colors cursor-pointer text-gray-400">
                <Layers className="w-6 h-6" />
                <span className="text-[10px]">Dívidas</span>
              </div>
              <div className="flex flex-col items-center gap-1 hover:bg-gray-50 hover:text-gray-900 rounded-xl px-3 py-1 transition-colors cursor-pointer text-gray-400">
                <LineChart className="w-6 h-6" />
                <span className="text-[10px]">Relatórios</span>
              </div>
            </div>
            <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-32 h-1 bg-black/20 rounded-full"></div>
          </div>
        </div>
      </div>
    </div>
  );
}

